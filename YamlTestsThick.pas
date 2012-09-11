unit YamlTestsThick;

interface

uses
  TestFramework,
  YamlDelphiFeatures, Yaml, CVariants;

implementation

uses
  SysUtils, DateUtils;

type
  TYamlTestsThick = class(TTestCase)
  published
    procedure TestLoad;
    procedure TestLoadAdvanced;
    procedure TestDumpAndLoad;
    procedure TestDateTime;
  end;

{ TYamlTestsThick }

procedure TYamlTestsThick.TestDateTime;
var
  NowValue: TDateTime;
  NowTxt: UTF8String;
begin
  NowValue := Now;
  NowTxt := DumpYaml(CDateTime(NowValue));
  Check(SameDateTime(NowValue, LoadYaml(NowTxt).ToDateTime), UTF8Decode(NowTxt) + ' is different from saved value');
end;

procedure TYamlTestsThick.TestDumpAndLoad;
begin
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
    ])), 'dump -> load -> equals test');
end;

procedure TYamlTestsThick.TestLoad;
begin
  Check(
    LoadYaml(
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
end;

procedure TYamlTestsThick.TestLoadAdvanced;
begin
  CheckTrue(
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

initialization
  RegisterTest(
    TTestSuite.Create('Yaml thick tests',
    [TYamlTestsThick.Suite]));
end.
