package geo_test


import "experimental/geo"
import "testing"
import "csv"

option now = () => 2030-01-01T00:00:00Z

inData =
    "
#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,string,string,string,double
#group,false,false,false,true,true,true,true,true,false
#default,,,,,,,,,
,result,table,_time,_start,_stop,_measurement,id,_field,_value
,,0,2019-01-04T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.03383
,,0,2019-01-02T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.14267
,,0,2019-01-01T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.16667
,,0,2019-01-01T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.18183
,,0,2019-01-01T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17367
,,0,2019-01-01T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17383
,,0,2019-01-02T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.2935
,,0,2019-01-02T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.3485
,,0,2019-01-02T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17383
,,0,2019-01-03T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.16633
,,0,2019-01-03T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.16633
,,0,2019-01-03T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17167
,,0,2019-01-03T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17383
,,0,2019-01-04T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.14683
,,0,2019-01-04T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17367
,,0,2019-01-04T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17433
,,0,2019-01-05T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.1595
,,0,2019-01-05T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.16
,,0,2019-01-05T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.16633
,,0,2019-01-05T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,latitude,21.17433
,,1,2019-01-04T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.09867
,,1,2019-01-02T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.17567
,,1,2019-01-01T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.16933
,,1,2019-01-01T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.17
,,1,2019-01-01T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.187
,,1,2019-01-01T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.18217
,,1,2019-01-02T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.15833
,,1,2019-01-02T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.15083
,,1,2019-01-02T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.181
,,1,2019-01-03T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.16883
,,1,2019-01-03T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.16883
,,1,2019-01-03T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.1815
,,1,2019-01-03T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.1845
,,1,2019-01-04T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.17433
,,1,2019-01-04T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.18667
,,1,2019-01-04T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.18167
,,1,2019-01-05T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.16733
,,1,2019-01-05T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.1665
,,1,2019-01-05T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.16817
,,1,2019-01-05T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,longitude,39.18417

#datatype,string,long,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,string,string,string,string
#group,false,false,false,true,true,true,true,true,false
#default,,,,,,,,,
,result,table,_time,_start,_stop,_measurement,id,_field,_value
,,2,2019-01-04T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-02T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-01T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-01T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-01T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-01T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-02T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-02T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-02T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-03T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-03T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-03T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-03T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-04T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-04T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-04T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-05T04:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-05T07:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-05T13:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
,,2,2019-01-05T19:00:00Z,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,migration,91916A,control,ctrlField
"
outData =
    "
#group,false,false,true,true,true,false,false,true,false,false,true
#datatype,string,long,string,dateTime:RFC3339,dateTime:RFC3339,dateTime:RFC3339,string,string,double,double,string
#default,_result,,,,,,,,,,
,result,table,_measurement,_start,_stop,_time,control,id,lat,lon,s2_cell_id
,,0,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-04T07:00:00Z,ctrlField,91916A,21.03383,39.09867,15c309
,,1,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-02T04:00:00Z,ctrlField,91916A,21.14267,39.17567,15c3a9
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-01T04:00:00Z,ctrlField,91916A,21.16667,39.16933,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-01T07:00:00Z,ctrlField,91916A,21.18183,39.17,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-01T13:00:00Z,ctrlField,91916A,21.17367,39.187,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-01T19:00:00Z,ctrlField,91916A,21.17383,39.18217,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-02T19:00:00Z,ctrlField,91916A,21.17383,39.181,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-03T04:00:00Z,ctrlField,91916A,21.16633,39.16883,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-03T07:00:00Z,ctrlField,91916A,21.16633,39.16883,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-03T13:00:00Z,ctrlField,91916A,21.17167,39.1815,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-03T19:00:00Z,ctrlField,91916A,21.17383,39.1845,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-04T04:00:00Z,ctrlField,91916A,21.14683,39.17433,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-04T13:00:00Z,ctrlField,91916A,21.17367,39.18667,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-04T19:00:00Z,ctrlField,91916A,21.17433,39.18167,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-05T04:00:00Z,ctrlField,91916A,21.1595,39.16733,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-05T07:00:00Z,ctrlField,91916A,21.16,39.1665,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-05T13:00:00Z,ctrlField,91916A,21.16633,39.16817,15c3af
,,2,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-05T19:00:00Z,ctrlField,91916A,21.17433,39.18417,15c3af
,,3,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-02T07:00:00Z,ctrlField,91916A,21.2935,39.15833,15c3b1
,,4,migration,2019-01-01T00:00:00Z,2019-01-02T00:00:00Z,2019-01-02T13:00:00Z,ctrlField,91916A,21.3485,39.15083,15c3b9
"

// Passes in flux, fails in C2 and OSS
testcase shapeData {
    got =
        csv.from(csv: inData)
            |> testing.load()
            |> range(start: 2019-01-01T00:00:00Z)
            |> geo.shapeData(latField: "latitude", lonField: "longitude", level: 10)
    want = csv.from(csv: outData)

    testing.diff(got, want)
}
