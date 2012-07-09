(**
 * @file yaml.h
 * @brief Public interface for libyaml.
 *)


unit YAML;

interface

uses
  SysUtils, Classes, YamlThin;


type
  (**
   * @defgroup version Version Information
   * @{
   *)

  IYamlVersion = interface
  ['{0B1F5CC2-3E4C-4D4C-922B-6E3F1EB871D8}']
    function GetAsString: string;
    function GetMajor: Integer;
    function GetMinor: Integer;
    function GetPatch: Integer;

  (**
   * Get the library version as a string.
   *
   * @returns The function returns the pointer to a static string of the form
   * @c "X.Y.Z", where @c X is the major version number, @c Y is a minor version
   * number, and @c Z is the patch version number.
   *)

    property AsString: string read GetAsString;

  (**
   * Get the library version numbers.
   *
   * @param[out]      major   Major version number.
   * @param[out]      minor   Minor version number.
   * @param[out]      patch   Patch version number.
   *)

    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
    property Patch: Integer read GetPatch;
  end;
function YamlVersion: IYamlVersion;
type

  (** @} *)

  (**
   * @defgroup basic Basic Types
   * @{
   *)

  (** The character type (UTF-8 octet). *)
  UString = WideString; // change to UnicodeString on XE2

  (** The version directive data. *)
  IYamlVersionDirective = interface
  ['{90DD4239-7F44-4B5A-B1D2-F5DCE8C1D41A}']
    function GetMajor: Integer;
    function GetMinor: Integer;
    (** The major version number. *)
    property Major: Integer read GetMajor;
    (** The minor version number. *)
    property Minor: Integer read GetMinor;
  end;

  (** The tag directive data. *)
  IYamlTagDirective = interface
  ['{C97DAEAC-9F62-4001-A23F-EF27ED5BF48D}']
    function GetHandle: UString;
    function GetPrefix: UString;
    (** The tag handle. *)
    property Handle: UString read GetHandle;
    (** The tag prefix. *)
    property Prefix: UString read GetPrefix;
  end;

  (** The stream encoding. *)
  TYamlEncoding = YamlThin.TYamlEncoding;

  (** Line break types. *)

  TYamlBreak = YamlThin.TYamlBreak;

  (** Many bad things could happen with the parser and emitter. *)
  EYamlError = class(Exception);
  (** No error is produced. *)
  // no error, no exception

  (** Cannot allocate or reallocate a block of memory. *)
  EYamlMemoryError = class(EYamlError);

  (** Cannot read or decode the input stream. *)
  EYamlReaderError = class(EYamlError);
  (** Cannot scan the input stream. *)
  EYamlScannerError = class(EYamlError);
  (** Cannot parse the input stream. *)
  EYamlParserError = class(EYamlError);
  (** Cannot compose a YAML document. *)
  EYamlComposerError = class(EYamlError);

  (** Cannot write to the output stream. *)
  EYamlWriterError = class(EYamlError);
  (** Cannot emit a YAML stream. *)
  EYamlEmitterError = class(EYamlError);

  (** The pointer position. *)
  // yaml_mark_t

  (** @} *)




implementation

// Thick binding

type
  TYamlVersionImpl = class(TInterfacedObject, IYamlVersion)
  public
    function GetAsString: string;
    function GetMajor: Integer;
    function GetMinor: Integer;
    function GetPatch: Integer;
    property AsString: string read GetAsString;
    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
    property Patch: Integer read GetPatch;
  end;

function YamlVersion: IYamlVersion;
begin
  Result := TYamlVersionImpl.Create;
end;

function TYamlVersionImpl.GetAsString: string;
begin
  Result := _yaml_get_version_string;
end;

function TYamlVersionImpl.GetMajor: Integer;
var
  Minor, Patch: Integer;
begin
  _yaml_get_version(Result, Minor, Patch);
end;

function TYamlVersionImpl.GetMinor: Integer;
var
  Major, Patch: Integer;
begin
  _yaml_get_version(Major, Result, Patch);
end;

function TYamlVersionImpl.GetPatch: Integer;
var
  Major, Minor: Integer;
begin
  _yaml_get_version(Major, Minor, Result);
end;



end.
