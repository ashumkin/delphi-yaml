unit Yaml.Tests.Thick;

interface

uses
  TestFramework,
  CVariants.DelphiFeatures, Yaml, CVariants;

implementation

uses
  SysUtils, DateUtils,
  Variants; // inline in XE2

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
  NowTxt := DumpYamlUtf8(CDateTime(NowValue));
  Check(SameDateTime(NowValue, LoadYamlUtf8(NowTxt).ToDateTime), UTF8ToUnicodeString(NowTxt) + ' is different from saved value');
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

initialization
  RegisterTest(
    TTestSuite.Create('Yaml thick tests',
    [TYamlTestsThick.Suite]));
end.
