package semantic

import (
	"sort"
	"strings"

	flatbuffers "github.com/google/flatbuffers/go"
	"github.com/influxdata/flux/codes"
	"github.com/influxdata/flux/internal/errors"
	"github.com/influxdata/flux/internal/fbsemantic"
)

// PolyType represents a polytype.  This struct is a thin wrapper around
// Go code generated by the FlatBuffers compiler.
type PolyType struct {
	fb *fbsemantic.PolyType
}

// NewPolyType returns a new polytype given a flatbuffers polytype.
func NewPolyType(fb *fbsemantic.PolyType) (PolyType, error) {
	if fb == nil {
		return PolyType{}, errors.New(codes.Internal, "got nil fbsemantic.polytype")
	}
	return PolyType{fb: fb}, nil
}

// NumVars returns the number of type variables in this polytype.
func (pt PolyType) NumVars() int {
	return pt.fb.VarsLength()
}

// Var returns the type variable at ordinal position i.
func (pt PolyType) Var(i int) (*fbsemantic.Var, error) {
	if i < 0 || i >= pt.NumVars() {
		return nil, errors.Newf(codes.Internal, "request for polytype var out of bounds: %v in %v", i, pt.NumVars())
	}
	v := new(fbsemantic.Var)
	if !pt.fb.Vars(v, i) {
		return nil, errors.Newf(codes.Internal, "missing var")
	}
	return v, nil
}

// NumConstraints returns the number of kind constraints in this polytype.
func (pt PolyType) NumConstraints() int {
	return pt.fb.ConsLength()
}

// Constraint returns the constraint at ordinal position i.
func (pt PolyType) Constraint(i int) (*fbsemantic.Constraint, error) {
	if i < 0 || i >= pt.NumConstraints() {
		return nil, errors.Newf(codes.Internal, "request for constraint out of bounds: %v in %v", i, pt.NumConstraints())
	}
	c := new(fbsemantic.Constraint)
	if !pt.fb.Cons(c, i) {
		return nil, errors.Newf(codes.Internal, "missing constraint")
	}
	return c, nil

}

// SortedConstraints returns the constraints for this polytype sorted by type variable and constraint kind.
func (pt *PolyType) SortedConstraints() ([]*fbsemantic.Constraint, error) {
	return pt.sortedConstraints(nil)
}

func (pt *PolyType) sortedConstraints(m map[uint64]uint64) ([]*fbsemantic.Constraint, error) {
	ncs := pt.NumConstraints()
	cs := make([]*fbsemantic.Constraint, ncs)
	for i := 0; i < ncs; i++ {
		c, err := pt.Constraint(i)
		if err != nil {
			return nil, err
		}
		cs[i] = c
	}
	sort.Slice(cs, func(i, j int) bool {
		var tvi, tvj uint64
		if m != nil {
			var ok bool
			tvi, ok = m[cs[i].Tvar(nil).I()]
			if !ok {
				panic("could not find var mapping")
			}
			tvj, ok = m[cs[j].Tvar(nil).I()]
			if !ok {
				panic("could not find var mapping")
			}
		} else {
			tvi, tvj = cs[i].Tvar(nil).I(), cs[j].Tvar(nil).I()
		}
		if tvi == tvj {
			return cs[i].Kind() < cs[j].Kind()
		}
		return tvi < tvj
	})
	return cs, nil
}

// Expr returns the monotype expression for this polytype.
func (pt PolyType) Expr() (MonoType, error) {
	var tbl flatbuffers.Table
	if !pt.fb.Expr(&tbl) {
		return MonoType{}, errors.New(codes.Internal, "missing a polytype expr")
	}

	return NewMonoType(tbl, pt.fb.ExprType())
}

func (pt PolyType) SortedVars() ([]*fbsemantic.Var, error) {
	return pt.sortedVars(nil)
}

func (pt PolyType) sortedVars(m map[uint64]uint64) ([]*fbsemantic.Var, error) {
	nvars := pt.NumVars()
	vars := make([]*fbsemantic.Var, nvars)
	for i := 0; i < nvars; i++ {
		arg, err := pt.Var(i)
		if err != nil {
			return nil, err
		}
		vars[i] = arg
	}
	sort.Slice(vars, func(i, j int) bool {
		var ii, jj uint64
		if m != nil {
			var ok bool
			if ii, ok = m[vars[i].I()]; !ok {
				panic("could not find var mapping")
			}
			if jj, ok = m[vars[j].I()]; !ok {
				panic("could not find var mapping")
			}
		} else {
			ii = vars[i].I()
			jj = vars[j].I()
		}

		return ii < jj
	})
	return vars, nil

}

// String returns a string representation for this polytype.
func (pt PolyType) String() string {
	return pt.string(nil)
}

// CanonicalString returns a string representation for this polytype,
// where the tvar numbers are contiguous and indexed starting at zero.
// Tvar numbers are ordered by the order they appear in the monotype expression.
func (pt PolyType) CanonicalString() string {
	m, err := pt.getCanonicalMapping()
	if err != nil {
		return "<" + err.Error() + ">"
	}
	return pt.string(m)
}

func (pt PolyType) string(m map[uint64]uint64) string {
	if pt.fb == nil {
		return "<polytype: nil>"
	}
	var sb strings.Builder

	sb.WriteString("forall [")
	needComma := false
	svars, err := pt.sortedVars(m)
	if err != nil {
		return "<" + err.Error() + ">"
	}
	for _, v := range svars {
		if needComma {
			sb.WriteString(", ")
		} else {
			needComma = true
		}
		mt := monoTypeFromVar(v)
		sb.WriteString(mt.string(m))
	}
	sb.WriteString("] ")

	needWhere := true
	cs, err := pt.sortedConstraints(m)
	if err != nil {
		return "<" + err.Error() + ">"
	}
	for i := 0; i < len(cs); i++ {
		cons := cs[i]
		tv := cons.Tvar(nil)
		k := cons.Kind()

		if needWhere {
			sb.WriteString("where ")
			needWhere = false
		}
		mtv := monoTypeFromVar(tv)
		sb.WriteString(mtv.string(m))
		sb.WriteString(": ")
		sb.WriteString(fbsemantic.EnumNamesKind[k])

		if i < pt.NumConstraints()-1 {
			sb.WriteString(", ")
		} else {
			sb.WriteString(" ")
		}
	}

	mt, err := pt.Expr()
	if err != nil {
		return "<" + err.Error() + ">"
	}
	sb.WriteString(mt.string(m))

	return sb.String()
}

// GetCanonicalMapping returns a map of type variable numbers to
// canonicalized numbers that start from 0.
// Tests that do type inference will have type variables that are sensitive
// to changes in the standard library, this helps to solve that problem.
func (pt *PolyType) getCanonicalMapping() (map[uint64]uint64, error) {
	tvm := make(map[uint64]uint64)
	counter := uint64(0)
	mt, err := pt.Expr()
	if err != nil {
		return nil, err
	}
	if err := mt.getCanonicalMapping(&counter, tvm); err != nil {
		return nil, err
	}

	nvars := pt.NumVars()
	for i := 0; i < nvars; i++ {
		// Normally all the tvars should already be in the mapping because we
		// have already visited the monotype expression.
		// However, for the sake of debugging issues like this one
		//   https://github.com/influxdata/flux/issues/2355
		// generate a mapping for the quantified vars just in case.
		v, err := pt.Var(i)
		if err != nil {
			return nil, err
		}
		updateTVarMap(&counter, tvm, v.I())
	}
	return tvm, nil
}
