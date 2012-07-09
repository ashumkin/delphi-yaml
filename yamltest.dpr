program yamltest;

{$APPTYPE CONSOLE}

uses
  Yaml in 'yaml.pas',
  YamlThin in 'yamlthin.pas',
  SysUtils;

begin
  WriteLn(YamlVersion.AsString);
  ReadLn;
end.
