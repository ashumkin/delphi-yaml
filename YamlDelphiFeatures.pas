unit
  YamlDelphiFeatures;

interface

{$INCLUDE 'YamlDelphiFeatures.inc'}

{$IFNDEF DELPHI_IS_UNICODE}
type
  UnicodeString = type WideString;
{$ENDIF}

{$IFNDEF DELPHI_HAS_UINT64}
type
  UInt64 = type Int64;
{$ENDIF}

implementation

end.