//go:build !fipsonly

package sql

// isDriverEnabled indicates if a given database driver is enabled.
// It is only intended to be used in test suites.
//
// This is a stopgap until all data base drivers can be supported
// in a FIPS compliant manner. Once that happens, it can be removed
// if desired.
func isDriverEnabled(driver string) bool {
	// All drivers are enabled in non-FIPS builds.
	return true
}

// disabledDriverError returns the error a driver gives when it is disabled.
func disabledDriverError(driver string) error {
	return nil
}
