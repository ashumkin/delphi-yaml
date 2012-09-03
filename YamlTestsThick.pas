unit YamlTestsThick;

interface

uses
  TestFramework,
  YamlDelphiFeatures, Yaml, CVariants;

implementation

type
  TYamlTestsThick = class(TTestCase)
  published
    procedure TestParse;
    procedure TestParseAdvanced;
  end;

{ TYamlTestsThick }

procedure TYamlTestsThick.TestParse;
begin
  CheckTrue(
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

procedure TYamlTestsThick.TestParseAdvanced;
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
