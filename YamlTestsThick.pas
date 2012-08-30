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
  end;

{ TYamlTestsThick }

procedure TYamlTestsThick.TestParse;
begin
  CheckTrue(
    FromYaml(
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

initialization
end.
