unit
  YamlDelphiFeatures;

interface

uses
  CVariantDelphiFeatures;

{$INCLUDE 'YamlDelphiFeatures.inc'}

{$IFNDEF DELPHI_IS_UNICODE}
type
  UnicodeString = CVariantDelphiFeatures.UnicodeString;
{$ENDIF}

{$IFNDEF DELPHI_HAS_UINT64}
type
  UInt64 = CVariantDelphiFeatures.UInt64;
{$ENDIF}

implementation

end.