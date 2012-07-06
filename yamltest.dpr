program yamltest;

{$APPTYPE CONSOLE}

uses
  yaml in 'yaml.pas',
  SysUtils;

begin
  WriteLn(CoYaml.Version.Get_String);
  ReadLn;
end.
