unit Yaml.Tests.Thick;

interface

uses
  TestFramework,
  CVariants.DelphiFeatures, Yaml, CVariants;

implementation

uses
  SysUtils, DateUtils, Yaml.Scalars,
  Variants, // inline in XE2
  Windows; // locale for floating point

type
  TYamlTestsThick = class(TTestCase)
  published
    procedure TestLoad;
    procedure TestLoadAdvanced;
    procedure TestDumpAndLoad;
    procedure TestDateTime;
    procedure TestDateTimeSpace;
    procedure TestFloating;
  end;

{ TYamlTestsThick }

procedure TYamlTestsThick.TestLoad;
begin
  Check(
    LoadYamlUtf8(
      'testdict:'#13#10 +
      '  - 2'#13#10 +
      '  -'#13#10 +
      '  - ["4", true]'#13#10 +
      '"another key": abc'#13#10
    ).Equals(
      CMap([
        'testdict',
          VList([
            2,
            nil,
            VList(['4', True])
          ]),
        'another key', 'abc'
      ])
    )
  );

  Check(
    LoadYaml(
      'another key: "abc"'#$D#$A +
      'testdict:'#$D#$A +
      '- 2'#$D#$A +
      '- null'#$D#$A +
      '- - "4"'#$D#$A +
      '  - true')
    .Equals(CMap([
      'testdict',
        VList([
          2,
          nil,
          VList(['4', True])
        ]),
      'another key', 'abc'
    ]))
  );
end;

procedure TYamlTestsThick.TestLoadAdvanced;
begin
  Check(
    LoadYamlUtf8(
      'testdict:'#13#10 +
      '  - 2'#13#10 +
      '  -'#13#10 +
      '  - ["4", true]'#13#10 +
      '"another key": abc'#13#10 +
      'something different:'#13#10 +
      '  - TRUE'#13#10 +
      '  - 20:2:02'#13#10 +
      '  - ''20:2:02'''#13#10 +
      '  - "20:2:02"'#13#10
    ).Equals(CMap([
      'testdict', VList([
        2,
        nil,
        VList(['4', True])
      ]),
      'another key', 'abc',
      'something different', VList([
        True,
        (20 * 60 + 2) * 60 + 2,
        '20:2:02',
        '20:2:02'
      ])
    ]))
  );

  Check(
    LoadYaml(
      'testdict:'#13#10 +
      '  - 2'#13#10 +
      '  -'#13#10 +
      '  - ["4", true]'#13#10 +
      '"another key": abc'#13#10 +
      'something different:'#13#10 +
      '  - TRUE'#13#10 +
      '  - 20:2:02'#13#10 +
      '  - ''20:2:02'''#13#10 +
      '  - "20:2:02"'#13#10
    ).Equals(CMap([
      'testdict', VList([
        2,
        nil,
        VList(['4', True])
      ]),
      'another key', 'abc',
      'something different', VList([
        True,
        (20 * 60 + 2) * 60 + 2,
        '20:2:02',
        '20:2:02'
      ])
    ]))
  );
end;

procedure TYamlTestsThick.TestDumpAndLoad;
begin
  Check(
    LoadYamlUtf8(DumpYamlUtf8(CMap([
      'testdict',
        VList([
          2,
          nil,
          VList(['4', True])
        ]),
      'another key', 'abc'
    ]))).Equals(CMap([
      'testdict',
        VList([
          2,
          nil,
          VList(['4', True])
        ]),
      'another key', 'abc'
    ])), 'dump -> load -> equals test (utf8)');

  Check(
    LoadYaml(DumpYaml(CMap([
      'testdict',
        VList([
          2,
          nil,
          VList(['4', True])
        ]),
      'another key', 'abc'
    ]))).Equals(CMap([
      'testdict',
        VList([
          2,
          nil,
          VList(['4', True])
        ]),
      'another key', 'abc'
    ])), 'dump -> load -> equals test (unicode)');
end;

procedure TYamlTestsThick.TestDateTime;
var
  NowValue: TDateTime;
  NowTxt: UTF8String;
begin
  NowValue := Now;
  NowTxt := DumpYamlUtf8(CDateTime(NowValue));
  Check(SameDateTime(NowValue, LoadYamlUtf8(NowTxt).ToDateTime), UTF8ToUnicodeString(NowTxt) + ' is different from saved value');
end;

procedure TYamlTestsThick.TestDateTimeSpace;
const
  ISODate = '2016-12-08T21:45:15.45+07:00';
  SpaceDate = '2016-12-08 21:45:15.45 +07:00';
var
  ISODateParsed, SpaceDateParsed: TDateTime;
begin
  ISODateParsed := LoadYamlUtf8(ISODate).ToDateTime;
  SpaceDateParsed := LoadYamlUtf8(SpaceDate).ToDateTime;
  Check(SameDateTime(ISODateParsed, SpaceDateParsed),
    UTF8ToUnicodeString(ISODate) + ' and ' + UTF8ToUnicodeString(SpaceDate) +
    ' were parsed to different values:' +
    UTF8ToUnicodeString(DumpYamlUtf8(CDateTime(ISODateParsed))) + ' and ' +
    UTF8ToUnicodeString(DumpYamlUtf8(CDateTime(SpaceDateParsed))));
end;

procedure TYamlTestsThick.TestFloating;
var
  ParsedFP: Double;
  FS: SysUtils.TFormatSettings;
begin
  SysUtils.GetLocaleFormatSettings($0409, FS);
  Check(Yaml.Scalars.YamlTryStrToFloat('0.00012345', ParsedFP), '''0.00012345'' parsed as scalar');
  Check(ParsedFP > 0.00012344, 'LoadYamlUtf8(''0.00012345'') = ' + FloatToStr(ParsedFP, FS));
  Check(ParsedFP < 0.00012346, 'LoadYamlUtf8(''0.00012345'') = ' + FloatToStr(ParsedFP, FS));
  Check(Yaml.Scalars.YamlTryStrToFloat('0.000012345e1', ParsedFP), '''0.000012345e1'' parsed as scalar');
  Check(ParsedFP > 0.00012344, 'LoadYamlUtf8(''0.000012345e1'') = ' + FloatToStr(ParsedFP, FS));
  Check(ParsedFP < 0.00012346, 'LoadYamlUtf8(''0.000012345e1'') = ' + FloatToStr(ParsedFP, FS));
  Check(Yaml.Scalars.YamlTryStrToFloat('0.0012345e-1', ParsedFP), '''0.0012345e-1'' parsed as scalar');
  Check(ParsedFP > 0.00012344, 'LoadYamlUtf8(''0.0012345e-1'') = ' + FloatToStr(ParsedFP, FS));
  Check(ParsedFP < 0.00012346, 'LoadYamlUtf8(''0.0012345e-1'') = ' + FloatToStr(ParsedFP, FS));
end;

initialization
  RegisterTest(
    TTestSuite.Create('Yaml thick tests',
    [TYamlTestsThick.Suite]));
end.
