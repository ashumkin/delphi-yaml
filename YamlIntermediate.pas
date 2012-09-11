(**
 * @file YamlIntermediate.pas
 * @brief Intermediate binding to libyaml
 *)


unit YamlIntermediate;

interface

uses
  SysUtils, Classes, Types, YamlThin, CVariantDelphiFeatures;

{$INCLUDE 'CVariantDelphiFeatures.inc'}

{$WARN UNSAFE_TYPE OFF} // PAnsiChar, PWideChar, untyped
{$WARN UNSAFE_CODE OFF} // @

type
  (**
   * @defgroup version Version Information
   * @{
   *)

  IYamlVersion = interface(IInterface)
  ['{0B1F5CC2-3E4C-4D4C-922B-6E3F1EB871D8}']
    function GetAsString: UnicodeString;
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

    property AsString: UnicodeString read GetAsString;

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
  YamlString = UnicodeString;

  (** The version directive data. *)
  IYamlVersionDirective = interface(IInterface)
  ['{90DD4239-7F44-4B5A-B1D2-F5DCE8C1D41A}']
    function GetMajor: Integer;
    function GetMinor: Integer;
    (** The major version number. *)
    property Major: Integer read GetMajor;
    (** The minor version number. *)
    property Minor: Integer read GetMinor;
  end;
  YamlVersionDirective = class
  public
    class function Create(Major, Minor: Integer): IYamlVersionDirective;
  end;

  (** The tag directive data. *)
  IYamlTagDirective = interface(IInterface)
  ['{C97DAEAC-9F62-4001-A23F-EF27ED5BF48D}']
    function GetHandle: YamlString;
    function GetPrefix: YamlString;
    (** The tag handle. *)
    property Handle: YamlString read GetHandle;
    (** The tag prefix. *)
    property Prefix: YamlString read GetPrefix;
  end;
  YamlTagDirective = class
  public
    class function Create(const Handle, Prefix: YamlString): IYamlTagDirective;
  end;
  TIYamlTagDirectiveDynArray = array of IYamlTagDirective;

  (** The stream encoding. *)
  TYamlEncoding = YamlThin.TYamlEncoding;
const
  (** Let the parser choose the encoding. *)
  yamlAnyEncoding = YamlThin.yamlAnyEncoding;
  (** The default UTF-8 encoding. *)
  yamlUtf8Encoding = YamlThin.yamlUtf8Encoding;
  (** The UTF-16-LE encoding with BOM. *)
  yamlUtf16leEncoding = YamlThin.yamlUtf16leEncoding;
  (** The UTF-16-BE encoding with BOM. *)
  yamlUtf16beEncoding = YamlThin.yamlUtf16beEncoding;

type
  (** Line break types. *)

  TYamlBreak = YamlThin.TYamlBreak;
const
  (** Let the parser choose the break type. *)
  yamlAnyBreak = YamlThin.yamlAnyBreak;
  (** Use CR for line breaks (Mac style). *)
  yamlCrBreak = YamlThin.yamlCrBreak;
  (** Use LN for line breaks (Unix style). *)
  yamlLnBreak = YamlThin.yamlLnBreak;
  (** Use CR LN for line breaks (DOS style). *)
  yamlCrLnBreak = YamlThin.yamlCrLnBreak;

type
  (** Many bad things could happen with the parser and emitter. *)
  EYamlError = class(EAbort);
  (** No error is produced. *)
  // no error, no exception

  (** Cannot allocate or reallocate a block of memory. *)
  EYamlMemoryError = class(EOutOfMemory);

  (** Cannot read or decode the input stream. *)
  IYamlMark = interface;
  EYamlReaderError = class(EYamlError)
  protected
    FProblem: YamlString;
    FProblemValue: Integer;
    FProblemOffset: Integer;
  public
    constructor Create(const Problem: YamlString; ProblemValue, ProblemOffset: Integer);
    property Problem: YamlString read FProblem;
    property ProblemValue: Integer read FProblemValue;
    property ProblemOffset: Integer read FProblemOffset;
  end;
  (** Cannot scan the input stream. *)
  EYamlScannerError = class(EYamlError)
  protected
    FContext, FProblem: YamlString;
    FContextMark, FProblemMark: IYamlMark;
  public
    constructor Create(const Context: YamlString; const ContextMark: IYamlMark;
      const Problem: YamlString; const ProblemMark: IYamlMark);
    property Context: YamlString read FContext;
    property ContextMark: IYamlMark read FContextMark;
    property Problem: YamlString read FProblem;
    property ProblemMark: IYamlMark read FProblemMark;
  end;
  (** Cannot parse the input stream. *)
  EYamlParserError = class(EYamlError)
  protected
    FProblem: YamlString;
    FProblemMark: IYamlMark;
  public
    constructor Create(const Problem: YamlString; const ProblemMark: IYamlMark);
    property Problem: YamlString read FProblem;
    property ProblemMark: IYamlMark read FProblemMark;
  end;
  (** Cannot compose a YAML document. *)
  EYamlComposerError = class(EYamlError)
  protected
    FContext, FProblem: YamlString;
    FContextMark, FProblemMark: IYamlMark;
  public
    constructor Create(const Context: YamlString; const ContextMark: IYamlMark;
      const Problem: YamlString; const ProblemMark: IYamlMark);
    property Context: YamlString read FContext;
    property ContextMark: IYamlMark read FContextMark;
    property Problem: YamlString read FProblem;
    property ProblemMark: IYamlMark read FProblemMark;
  end;
  (** Cannot construct a native data structure. *)
  EYamlConstructorError = class(EYamlError)
  protected
    FContext, FProblem: YamlString;
    FContextMark, FProblemMark: IYamlMark;
  public
    constructor Create(const Context: YamlString; const ContextMark: IYamlMark;
      const Problem: YamlString; const ProblemMark: IYamlMark);
    property Context: YamlString read FContext;
    property ContextMark: IYamlMark read FContextMark;
    property Problem: YamlString read FProblem;
    property ProblemMark: IYamlMark read FProblemMark;
  end;

  (** Cannot write to the output stream. *)
  EYamlWriterError = class(EYamlError)
  protected
    FProblem: YamlString;
  public
    constructor Create(const Problem: YamlString);
    property Problem: YamlString read FProblem;
  end;
  (** Cannot emit a YAML stream. *)
  EYamlEmitterError = class(EYamlError)
  protected
    FProblem: YamlString;
  public
    constructor Create(const Problem: YamlString);
    property Problem: YamlString read FProblem;
  end;
  (** Cannot represent native data structure. *)
  EYamlRepresenterError = class(EYamlError)
  protected
    FProblem: YamlString;
  public
    constructor Create(const Problem: YamlString);
    property Problem: YamlString read FProblem;
  end;

  (** The pointer position. *)
  IYamlMark = interface(IInterface)
  ['{DB5BD8F3-5703-44D6-9237-D014E0748459}']
    function GetIndex: Integer;
    function GetLine: Integer;
    function GetColumn: Integer;
    (** The position index. *)
    property Index: Integer read GetIndex;

    (** The position line. *)
    property Line: Integer read GetLine;

    (** The position column. *)
    property Column: Integer read GetColumn;
  end;

  (** @} *)

  (**
   * @defgroup styles Node Styles
   * @{
   *)

  (** Scalar styles. *)
  TYamlScalarStyle = YamlThin.TYamlScalarStyle;
const
  (** Let the emitter choose the style. *)
  yamlAnyScalarStyle = YamlThin.yamlAnyScalarStyle;

  (** The plain scalar style. *)
  yamlPlainScalarStyle = YamlThin.yamlPlainScalarStyle;

  (** The single-quoted scalar style. *)
  yamlSingleQuotedScalarStyle = YamlThin.yamlSingleQuotedScalarStyle;
  (** The double-quoted scalar style. *)
  yamlDoubleQuotedScalarStyle = YamlThin.yamlDoubleQuotedScalarStyle;

  (** The literal scalar style. *)
  yamlLiteralScalarStyle = YamlThin.yamlLiteralScalarStyle;
  (** The folded scalar style. *)
  yamlFoldedScalarStyle = YamlThin.yamlFoldedScalarStyle;

type
  (** Sequence styles. *)
  TYamlSequenceStyle = YamlThin.TYamlSequenceStyle;
const
  (** Let the emitter choose the style. *)
  yamlAnySequenceStyle = YamlThin.yamlAnySequenceStyle;

  (** The block sequence style. *)
  yamlBlockSequenceStyle = YamlThin.yamlBlockSequenceStyle;
  (** The flow sequence style. *)
  yamlFlowSequenceStyle = YamlThin.yamlFlowSequenceStyle;

type
  (** Mapping styles. *)
  TYamlMappingStyle = YamlThin.TYamlMappingStyle;
const
  (** Let the emitter choose the style. *)
  yamlAnyMappingStyle = YamlThin.yamlAnyMappingStyle;

  (** The block mapping style. *)
  yamlBlockMappingStyle = YamlThin.yamlBlockMappingStyle;
  (** The flow mapping style. *)
  yamlFlowMappingStyle = YamlThin.yamlFlowMappingStyle;
  (*  YAML_FLOW_SET_MAPPING_STYLE   *)

type
  (** @} *)

  (**
   * @defgroup tokens Tokens
   * @{
   *)

  (** Token types. *)
  TYamlTokenType = YamlThin.TYamlTokenType;
const
  (** An empty token. *)
  yamlNoToken = YamlThin.yamlNoToken;

  (** A STREAM-START token. *)
  yamlStreamStartToken = YamlThin.yamlStreamStartToken;
  (** A STREAM-END token. *)
  yamlStreamEndToken = YamlThin.yamlStreamEndToken;

  (** A VERSION-DIRECTIVE token. *)
  yamlVersionDirectiveToken = YamlThin.yamlVersionDirectiveToken;
  (** A TAG-DIRECTIVE token. *)
  yamlTagDirectiveToken = YamlThin.yamlTagDirectiveToken;
  (** A DOCUMENT-START token. *)
  yamlDocumentStartToken = YamlThin.yamlDocumentStartToken;
  (** A DOCUMENT-END token. *)
  yamlDocumentEndToken = YamlThin.yamlDocumentEndToken;

  (** A BLOCK-SEQUENCE-START token. *)
  yamlBlockSequenceStartToken = YamlThin.yamlBlockSequenceStartToken;
  (** A BLOCK-SEQUENCE-END token. *)
  yamlBlockMappingStartToken = YamlThin.yamlBlockMappingStartToken;
  (** A BLOCK-END token. *)
  yamlBlockEndToken = YamlThin.yamlBlockEndToken;

  (** A FLOW-SEQUENCE-START token. *)
  yamlFlowSequenceStartToken = YamlThin.yamlFlowSequenceStartToken;
  (** A FLOW-SEQUENCE-END token. *)
  yamlFlowSequenceEndToken = YamlThin.yamlFlowSequenceEndToken;
  (** A FLOW-MAPPING-START token. *)
  yamlFlowMappingStartToken = YamlThin.yamlFlowMappingStartToken;
  (** A FLOW-MAPPING-END token. *)
  yamlFlowMappingEndToken = YamlThin.yamlFlowMappingEndToken;

  (** A BLOCK-ENTRY token. *)
  yamlBlockEntryToken = YamlThin.yamlBlockEntryToken;
  (** A FLOW-ENTRY token. *)
  yamlFlowEntryToken = YamlThin.yamlFlowEntryToken;
  (** A KEY token. *)
  yamlKeyToken = YamlThin.yamlKeyToken;
  (** A VALUE token. *)
  yamlValueToken = YamlThin.yamlValueToken;

  (** An ALIAS token. *)
  yamlAliasToken = YamlThin.yamlAliasToken;
  (** An ANCHOR token. *)
  yamlAnchorToken = YamlThin.yamlAnchorToken;
  (** A TAG token. *)
  yamlTagToken = YamlThin.yamlTagToken;
  (** A SCALAR token. *)
  yamlScalarToken = YamlThin.yamlScalarToken;

type
  (** The token structure. *)
  IYamlToken = interface(IInterface)
  ['{AB5E049D-123D-45EB-BFB3-D7B5424AECB4}']
    function GetTokenType: TYamlTokenType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetAliasValue: YamlString;
    function GetAnchorValue: YamlString;
    function GetTagHandle: YamlString;
    function GetTagSuffix: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirective: IYamlTagDirective;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    (** The token type. *)
    property TokenType: TYamlTokenType read GetTokenType;

    (** The token data. *)

      (** The stream start (for @c YAML_STREAM_START_TOKEN). *)
        (** The stream encoding. *)
        property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;

      (** The alias (for @c YAML_ALIAS_TOKEN). *)
        (** The alias value. *)
        property AliasValue: YamlString read GetAliasValue;

      (** The anchor (for @c YAML_ANCHOR_TOKEN). *)
        (** The anchor value. *)
        property AnchorValue: YamlString read GetAnchorValue;

      (** The tag (for @c YAML_TAG_TOKEN). *)
        (** The tag handle. *)
        property TagHandle: YamlString read GetTagHandle;
        (** The tag suffix. *)
        property TagSuffix: YamlString read GetTagSuffix;

      (** The scalar value (for @c YAML_SCALAR_TOKEN). *)
        (** The scalar value. *)
        property ScalarValue: YamlString read GetScalarValue;
        (** The length of the scalar value. *)
        // ScalarLength
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The version directive (for @c YAML_VERSION_DIRECTIVE_TOKEN). *)
      property VersionDirective: IYamlVersionDirective read GetVersionDirective;

      (** The tag directive (for @c YAML_TAG_DIRECTIVE_TOKEN). *)
      property TagDirective: IYamlTagDirective read GetTagDirective;

    (** The beginning of the token. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the token. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (**
   * Free any memory allocated for a token object.
   *
   * @param[in,out]   token   A token object.
   *)

  // yaml_token_delete

  (** @} *)

  (**
   * @defgroup events Events
   * @{
   *)

  (** Event types. *)
  TYamlEventType = YamlThin.TYamlEventType;
const
  (** An empty event. *)
  yamlNoEvent = YamlThin.yamlNoEvent;

  (** A STREAM-START event. *)
  yamlStreamStartEvent = YamlThin.yamlStreamStartEvent;
  (** A STREAM-END event. *)
  yamlStreamEndEvent = YamlThin.yamlStreamEndEvent;

  (** A DOCUMENT-START event. *)
  yamlDocumentStartEvent = YamlThin.yamlDocumentStartEvent;
  (** A DOCUMENT-END event. *)
  yamlDocumentEndEvent = YamlThin.yamlDocumentEndEvent;

  (** An ALIAS event. *)
  yamlAliasEvent = YamlThin.yamlAliasEvent;
  (** A SCALAR event. *)
  yamlScalarEvent = YamlThin.yamlScalarEvent;

  (** A SEQUENCE-START event. *)
  yamlSequenceStartEvent = YamlThin.yamlSequenceStartEvent;
  (** A SEQUENCE-END event. *)
  yamlSequenceEndEvent = YamlThin.yamlSequenceEndEvent;

  (** A MAPPING-START event. *)
  yamlMappingStartEvent = YamlThin.yamlMappingStartEvent;
  (** A MAPPING-END event. *)
  yamlMappingEndEvent = YamlThin.yamlMappingEndEvent;

type
  (** The event structure. *)
  IYamlEvent = interface(IInterface)
  ['{12F279D3-BADF-4F5E-8E4E-D895D0A20AF0}']
    function GetEventType: TYamlEventType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetDocumentStartVersionDirective: IYamlVersionDirective;
    function GetDocumentStartTagDirectives: TIYamlTagDirectiveDynArray;
    function GetDocumentStartImplicit: Boolean;
    function GetDocumentEndImplicit: Boolean;
    function GetAliasAnchor: YamlString;
    function GetScalarAnchor: YamlString;
    function GetScalarTag: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarPlainImplicit: Boolean;
    function GetScalarQuotedImplicit: Boolean;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceStartAnchor: YamlString;
    function GetSequenceStartTag: YamlString;
    function GetSequenceStartImplicit: Boolean;
    function GetSequenceStartStyle: TYamlSequenceStyle;
    function GetMappingStartAnchor: YamlString;
    function GetMappingStartTag: YamlString;
    function GetMappingStartImplicit: Boolean;
    function GetMappingStartStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    (** The event type. *)
    property EventType: TYamlEventType read GetEventType;

    (** The event data. *)

      (** The stream parameters (for @c YAML_STREAM_START_EVENT). *)
        (** The document encoding. *)
        property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;

      (** The document parameters (for @c YAML_DOCUMENT_START_EVENT). *)
        (** The version directive. *)
        property DocumentStartVersionDirective: IYamlVersionDirective read GetDocumentStartVersionDirective;

        (** The list of tag directives. *)
        property DocumentStartTagDirectives: TIYamlTagDirectiveDynArray read GetDocumentStartTagDirectives;

        (** Is the document indicator implicit? *)
        property DocumentStartImplicit: Boolean read GetDocumentStartImplicit;

      (** The document end parameters (for @c YAML_DOCUMENT_END_EVENT). *)
        (** Is the document end indicator implicit? *)
        property DocumentEndImplicit: Boolean read GetDocumentEndImplicit;

      (** The alias parameters (for @c YAML_ALIAS_EVENT). *)
        (** The anchor. *)
        property AliasAnchor: YamlString read GetAliasAnchor;

      (** The scalar parameters (for @c YAML_SCALAR_EVENT). *)
        (** The anchor. *)
        property ScalarAnchor: YamlString read GetScalarAnchor;
        (** The tag. *)
        property ScalarTag: YamlString read GetScalarTag;
        (** The scalar value. *)
        property ScalarValue: YamlString read GetScalarValue;
        (** The length of the scalar value. *)
        // ScalarLength
        (** Is the tag optional for the plain style? *)
        property ScalarPlainImplicit: Boolean read GetScalarPlainImplicit;
        (** Is the tag optional for any non-plain style? *)
        property ScalarQuotedImplicit: Boolean read GetScalarQuotedImplicit;
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The sequence parameters (for @c YAML_SEQUENCE_START_EVENT). *)
        (** The anchor. *)
        property SequenceStartAnchor: YamlString read GetSequenceStartAnchor;
        (** The tag. *)
        property SequenceStartTag: YamlString read GetSequenceStartTag;
        (** Is the tag optional? *)
        property SequenceStartImplicit: Boolean read GetSequenceStartImplicit;
        (** The sequence style. *)
        property SequenceStartStyle: TYamlSequenceStyle read GetSequenceStartStyle;

      (** The mapping parameters (for @c YAML_MAPPING_START_EVENT). *)
        (** The anchor. *)
        property MappingStartAnchor: YamlString read GetMappingStartAnchor;
        (** The tag. *)
        property MappingStartTag: YamlString read GetMappingStartTag;
        (** Is the tag optional? *)
        property MappingStartImplicit: Boolean read GetMappingStartImplicit;
        (** The mapping style. *)
        property MappingStartStyle: TYamlMappingStyle read GetMappingStartStyle;

    (** The beginning of the event. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the event. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (**
   * Create the STREAM-START event.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       encoding    The stream encoding.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventStreamStart = class
  public
    class function Create(Encoding: TYamlEncoding): IYamlEvent;
  end;

  (**
   * Create the STREAM-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventStreamEnd = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Create the DOCUMENT-START event.
   *
   * The @a implicit argument is considered as a stylistic parameter and may be
   * ignored by the emitter.
   *
   * @param[out]      event                   An empty event object.
   * @param[in]       version_directive       The %YAML directive value or
   *                                          @c NULL.
   * @param[in]       tag_directives_start    The beginning of the %TAG
   *                                          directives list.
   * @param[in]       tag_directives_end      The end of the %TAG directives
   *                                          list.
   * @param[in]       implicit                If the document start indicator is
   *                                          implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventDocumentStart = class
  public
    class function Create(const VersionDirective: IYamlVersionDirective;
      const TagDirectives: array of IYamlTagDirective;
      Implicit: Boolean): IYamlEvent;
  end;

  (**
   * Create the DOCUMENT-END event.
   *
   * The @a implicit argument is considered as a stylistic parameter and may be
   * ignored by the emitter.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       implicit    If the document end indicator is implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventDocumentEnd = class
  public
    class function Create(Implicit: Boolean): IYamlEvent;
  end;

  (**
   * Create an ALIAS event.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The anchor value.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventAlias = class
  public
    class function Create(const Anchor: YamlString): IYamlEvent;
  end;

  (**
   * Create a SCALAR event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or one of the @a plain_implicit and
   * @a quoted_implicit flags must be set.
   *
   * @param[out]      event           An empty event object.
   * @param[in]       anchor          The scalar anchor or @c NULL.
   * @param[in]       tag             The scalar tag or @c NULL.
   * @param[in]       value           The scalar value.
   * @param[in]       length          The length of the scalar value.
   * @param[in]       plain_implicit  If the tag may be omitted for the plain
   *                                  style.
   * @param[in]       quoted_implicit If the tag may be omitted for any
   *                                  non-plain style.
   * @param[in]       style           The scalar style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventScalar = class
  public
    class function Create(const Anchor, Tag, Value: YamlString;
      PlainImplicit, QuotedImplicit: Boolean;
      Style: TYamlScalarStyle): IYamlEvent;
  end;

  (**
   * Create a SEQUENCE-START event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or the @a implicit flag must be set.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The sequence anchor or @c NULL.
   * @param[in]       tag         The sequence tag or @c NULL.
   * @param[in]       implicit    If the tag may be omitted.
   * @param[in]       style       The sequence style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventSequenceStart = class
  public
    class function Create(const Anchor, Tag: YamlString; Implicit: Boolean;
      Style: TYamlSequenceStyle): IYamlEvent;
  end;

  (**
   * Create a SEQUENCE-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventSequenceEnd = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Create a MAPPING-START event.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * Either the @a tag attribute or the @a implicit flag must be set.
   *
   * @param[out]      event       An empty event object.
   * @param[in]       anchor      The mapping anchor or @c NULL.
   * @param[in]       tag         The mapping tag or @c NULL.
   * @param[in]       implicit    If the tag may be omitted.
   * @param[in]       style       The mapping style.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventMappingStart = class
  public
    class function Create(const Anchor, Tag: YamlString; Implicit: Boolean;
      Style: TYamlMappingStyle): IYamlEvent;
  end;

  (**
   * Create a MAPPING-END event.
   *
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlEventMappingEnd = class
  public
    class function Create: IYamlEvent;
  end;

  (**
   * Free any memory allocated for an event object.
   *
   * @param[in,out]   event   An event object.
   *)

  // yaml_event_delete

  (** @} *)

  (**
   * @defgroup nodes Nodes
   * @{
   *)

  (** The tag @c !!null with the only possible value: @c null. *)
const yamlNullTag      = YamlThin.yamlNullTag;
  (** The tag @c !!bool with the values: @c true and @c false. *)
const yamlBoolTag      = YamlThin.yamlBoolTag;
  (** The tag @c !!str for string values. *)
const yamlStrTag       = YamlThin.yamlStrTag;
  (** The tag @c !!int for integer values. *)
const yamlIntTag       = YamlThin.yamlIntTag;
  (** The tag @c !!float for float values. *)
const yamlFloatTag     = YamlThin.yamlFloatTag;
  (** The tag @c !!timestamp for date and time values. *)
const yamlTimestampTag = YamlThin.yamlTimestampTag;

  (** The tag @c !!seq is used to denote sequences. *)
const yamlSeqTag       = YamlThin.yamlSeqTag;
  (** The tag @c !!map is used to denote mapping. *)
const yamlMapTag       = YamlThin.yamlMapTag;

  (** The default scalar tag is @c !!str. *)
const yamlDefaultScalarTag    = yamlStrTag;
  (** The default sequence tag is @c !!seq. *)
const yamlDefaultSequenceTag  = yamlSeqTag;
  (** The default mapping tag is @c !!map. *)
const yamlDefaultMappingTag   = yamlMapTag;

  (** Node types. *)
type
  TYamlNodeType = YamlThin.TYamlNodeType;
const
  (** An empty node. *)
  yamlNoNode = YamlThin.yamlNoNode;

  (** A scalar node. *)
  yamlScalarNode = YamlThin.yamlScalarNode;
  (** A sequence node. *)
  yamlSequenceNode = YamlThin.yamlSequenceNode;
  (** A mapping node. *)
  yamlMappingNode = YamlThin.yamlMappingNode;

type
  (** The forward definition of a document structure. *)
  IYamlDocument = interface;

  (** An element of a sequence node. *)
  IYamlNode = interface;
  TIYamlNodeDynArray = array of IYamlNode;

  (** An element of a mapping node. *)
  TYamlNodePair = record
    (** The key of the element. *)
    Key: IYamlNode;
    (** The value of the element. *)
    Value: IYamlNode;
  end;
  TYamlNodePairDynArray = array of TYamlNodePair;

  (** The node structure. *)
  IYamlNode = interface(IInterface)
  ['{4A158305-AC46-41AA-86E5-10AC082C14D9}']
    function GetDocument: IYamlDocument;
    function GetId: Integer; // ids start from 0 while in thin libyaml they start from 1
    function GetNodeType: TYamlNodeType;
    function GetTag: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceItems: TIYamlNodeDynArray;
    procedure AppendSequenceItem(Item: IYamlNode);
    function GetSequenceStyle: TYamlSequenceStyle;
    function GetMappingPairs: TYamlNodePairDynArray;
    procedure AppendMappingPair(Key, Value: IYamlNode);
    function GetMappingStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;
    property Document: IYamlDocument read GetDocument;
    property Id: Integer read GetId;

    (** The node type. *)
    property NodeType: TYamlNodeType read GetNodeType;

    (** The node tag. *)
    property Tag: YamlString read GetTag;

    (** The node data. *)
      (** The scalar parameters (for @c YAML_SCALAR_NODE). *)
        (** The scalar value. *)
        property ScalarValue: YamlString read GetScalarValue;
        (** The scalar style. *)
        property ScalarStyle: TYamlScalarStyle read GetScalarStyle;

      (** The sequence parameters (for @c YAML_SEQUENCE_NODE). *)
        (** The stack of sequence items. *)
        property SequenceItems: TIYamlNodeDynArray read GetSequenceItems;
        (** The sequence style. *)
        property SequenceStyle: TYamlSequenceStyle read GetSequenceStyle;

      (** The mapping parameters (for @c YAML_MAPPING_NODE). *)
        (** The stack of mapping pairs (key, value). *)
        property MappingPairs: TYamlNodePairDynArray read GetMappingPairs;
        (** The mapping style. *)
        property MappingStyle: TYamlMappingStyle read GetMappingStyle;

    (** The beginning of the node. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the node. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (** The document structure. *)
  IYamlDocument = interface(IInterface)
  ['{276D0A02-F531-4DBC-9459-44D2CF6E7AED}']
    function GetNodes: TIYamlNodeDynArray;
    function GetRootNode: IYamlNode; // nil when document is empty
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirectives: TIYamlTagDirectiveDynArray;
    function GetStartImplicit: Boolean;
    function GetEndImplicit: Boolean;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    function CreateScalar(const Tag, Value: YamlString; Style: TYamlScalarStyle): IYamlNode;
    function CreateSequence(const Tag: YamlString; Style: TYamlScalarStyle): IYamlNode;
    function CreateMapping(const Tag: YamlString; Style: TYamlMappingStyle): IYamlNode;

    (** The document nodes. *)
    property Nodes: TIYamlNodeDynArray read GetNodes;
    property RootNode: IYamlNode read GetRootNode;

    (** The version directive. *)
    property VersionDirective: IYamlVersionDirective read GetVersionDirective;

    (** The list of tag directives. *)
    property TagDirectives: TIYamlTagDirectiveDynArray read GetTagDirectives;

    (** Is the document start indicator implicit? *)
    property StartImplicit: Boolean read GetStartImplicit;
    (** Is the document end indicator implicit? *)
    property EndImplicit: Boolean read GetEndImplicit;

    (** The beginning of the document. *)
    property StartMark: IYamlMark read GetStartMark;
    (** The end of the document. *)
    property EndMark: IYamlMark read GetEndMark;

  end;

  (**
   * Create a YAML document.
   *
   * @param[out]      document                An empty document object.
   * @param[in]       version_directive       The %YAML directive value or
   *                                          @c NULL.
   * @param[in]       tag_directives_start    The beginning of the %TAG
   *                                          directives list.
   * @param[in]       tag_directives_end      The end of the %TAG directives
   *                                          list.
   * @param[in]       start_implicit          If the document start indicator is
   *                                          implicit.
   * @param[in]       end_implicit            If the document end indicator is
   *                                          implicit.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  YamlDocument = class
  public
    class function Create(const VersionDirective: IYamlVersionDirective;
      const TagDirectives: array of IYamlTagDirective;
      StartImplicit, EndImplicit: Boolean): IYamlDocument;
  end;

  (**
   * Delete a YAML document and all its nodes.
   *
   * @param[in,out]   document        A document object.
   *)

  // yaml_document_delete

  (**
   * Get a node of a YAML document.
   *
   * The pointer returned by this function is valid until any of the functions
   * modifying the documents are called.
   *
   * @param[in]       document        A document object.
   * @param[in]       index           The node id.
   *
   * @returns the node objct or @c NULL if @c node_id is out of range.
   *)

  // yaml_document_get_node

  (**
   * Get the root of a YAML document node.
   *
   * The root object is the first object added to the document.
   *
   * The pointer returned by this function is valid until any of the functions
   * modifying the documents are called.
   *
   * An empty document produced by the parser signifies the end of a YAML
   * stream.
   *
   * @param[in]       document        A document object.
   *
   * @returns the node object or @c NULL if the document is empty.
   *)

  // yaml_document_get_root_node

  (**
   * Create a SCALAR node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document        A document object.
   * @param[in]       tag             The scalar tag.
   * @param[in]       value           The scalar value.
   * @param[in]       length          The length of the scalar value.
   * @param[in]       style           The scalar style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_scalar

  (**
   * Create a SEQUENCE node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       tag         The sequence tag.
   * @param[in]       style       The sequence style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_sequence

  (**
   * Create a MAPPING node and attach it to the document.
   *
   * The @a style argument may be ignored by the emitter.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       tag         The sequence tag.
   * @param[in]       style       The sequence style.
   *
   * @returns the node id or @c 0 on error.
   *)

  // yaml_document_add_mapping

  (**
   * Add an item to a SEQUENCE node.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       sequence    The sequence node id.
   * @param[in]       item        The item node id.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_document_append_sequence_item

  (**
   * Add a pair of a key and a value to a MAPPING node.
   *
   * @param[in,out]   document    A document object.
   * @param[in]       mapping     The mapping node id.
   * @param[in]       key         The key node id.
   * @param[in]       value       The value node id.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_document_append_mapping_pair

  (** @} *)

  (**
   * @defgroup parser Parser Definitions
   * @{
   *)

  (**
   * The prototype of a read handler.
   *
   * The read handler is called when the parser needs to read more bytes from the
   * source.  The handler should write not more than @a size bytes to the @a
   * buffer.  The number of written bytes should be set to the @a length variable.
   *
   * @param[in,out]   data        A pointer to an application data specified by
   *                              yaml_parser_set_input().
   * @param[out]      buffer      The buffer to write the data from the source.
   * @param[in]       size        The size of the buffer.
   * @param[out]      size_read   The actual number of bytes read from the source.
   *
   * @returns On success, the handler should return @c 1.  If the handler failed,
   * the returned value should be @c 0.  On EOF, the handler should set the
   * @a size_read to @c 0 and return @c 1.
   *)

  IYamlInput = interface(IInterface)
  ['{FD5414B7-6C22-4BA5-ADF0-326998A02324}']
    function GetIsEof: Boolean;
    function Read(var Buffer; Size: Integer): Integer;
    function GetEncoding: TYamlEncoding;
    property IsEof: Boolean read GetIsEof;
    property Encoding: TYamlEncoding read GetEncoding;
  end;

  (**
   * This structure holds information about a potential simple key.
   *)

  // yaml_simple_key_t

  (**
   * The states of the parser.
   *)
  // yaml_parser_state_t

  (**
   * This structure holds aliases data.
   *)

  // yaml_alias_data_t

  (**
   * The parser structure.
   *
   * All members are internal.  Manage the structure using the @c yaml_parser_
   * family of functions.
   *)

  // yaml_parser_t

  (**
   * Initialize a parser.
   *
   * This function creates a new parser object.  An application is responsible
   * for destroying the object using the yaml_parser_delete() function.
   *
   * @param[out]      parser  An empty parser object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_parser_initialize

  (**
   * Destroy a parser.
   *
   * @param[in,out]   parser  A parser object.
   *)

  // yaml_parser_delete

  (**
   * Set a string input.
   *
   * Note that the @a input pointer must be valid while the @a parser object
   * exists.  The application is responsible for destroing @a input after
   * destroying the @a parser.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       input   A source data.
   * @param[in]       size    The length of the source data in bytes.
   *)

  YamlInput = class
  public
    class function Create(const Input; Size: Integer; Copy: Boolean = True;
      Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput; overload;
    class function Create(Input: PAnsiChar; Size: Integer = -1; Copy: Boolean = True;
      Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput; overload;
    class function Create(const Input: UTF8String;
      Encoding: TYamlEncoding = yamlUtf8Encoding): IYamlInput; overload;
    class function Create(const Input: WideString;
      Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlInput; overload;
    class function Create(Input: PWideChar; SizeInWideChars: Integer = -1; Copy: Boolean = True;
      Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlInput; overload;
    class function Create(const Input: TByteDynArray;
      Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput; overload;

  (**
   * Set a file input.
   *
   * @a file should be a file object open for reading.  The application is
   * responsible for closing the @a file.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       file    An open file.
   *)

    class function Create(Input: TStream;
      Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput; overload;
  end;

  (**
   * Set a generic input handler.
   *
   * @param[in,out]   parser  A parser object.
   * @param[in]       handler A read handler.
   * @param[in]       data    Any application data for passing to the read
   *                          handler.
   *)

  // yaml_parser_set_input

  (**
   * Set the source encoding.
   *
   * @param[in,out]   parser      A parser object.
   * @param[in]       encoding    The source encoding.
   *)

  // yaml_parser_set_encoding

  (**
   * Scan the input stream and produce the next token.
   *
   * Call the function subsequently to produce a sequence of tokens corresponding
   * to the input stream.  The initial token has the type
   * @c YAML_STREAM_START_TOKEN while the ending token has the type
   * @c YAML_STREAM_END_TOKEN.
   *
   * An application is responsible for freeing any buffers associated with the
   * produced token object using the @c yaml_token_delete function.
   *
   * An application must not alternate the calls of yaml_parser_scan() with the
   * calls of yaml_parser_parse() or yaml_parser_load(). Doing this will break
   * the parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      token       An empty token object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  IYamlTokenParser = interface(IInterface)
  ['{89C50981-0DB4-4E54-8412-FE9FD999B608}']
    function Next(var Token: IYamlToken): Boolean;
  end;
  YamlTokenParser = class
  public
    class function Create(const Input: IYamlInput): IYamlTokenParser;
  end;

  (**
   * Parse the input stream and produce the next parsing event.
   *
   * Call the function subsequently to produce a sequence of events corresponding
   * to the input stream.  The initial event has the type
   * @c YAML_STREAM_START_EVENT while the ending event has the type
   * @c YAML_STREAM_END_EVENT.
   *
   * An application is responsible for freeing any buffers associated with the
   * produced event object using the yaml_event_delete() function.
   *
   * An application must not alternate the calls of yaml_parser_parse() with the
   * calls of yaml_parser_scan() or yaml_parser_load(). Doing this will break the
   * parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      event       An empty event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  IYamlEventParser = interface(IInterface)
  ['{48F38085-102F-44C3-A05B-9D2FCA912731}']
    function Next(var Event: IYamlEvent): Boolean;
  end;
  YamlEventParser = class
  public
    class function Create(const Input: IYamlInput): IYamlEventParser;
  end;

  (**
   * Parse the input stream and produce the next YAML document.
   *
   * Call this function subsequently to produce a sequence of documents
   * constituting the input stream.
   *
   * If the produced document has no root node, it means that the document
   * end has been reached.
   *
   * An application is responsible for freeing any data associated with the
   * produced document object using the yaml_document_delete() function.
   *
   * An application must not alternate the calls of yaml_parser_load() with the
   * calls of yaml_parser_scan() or yaml_parser_parse(). Doing this will break
   * the parser.
   *
   * @param[in,out]   parser      A parser object.
   * @param[out]      document    An empty document object.
   *
   * @return @c 1 if the function succeeded, @c 0 on error.
   *)

  IYamlDocumentParser = interface(IInterface)
  ['{6FDBFA28-C462-4A78-ACF5-974021ADBE67}']
    function Next(var Document: IYamlDocument): Boolean;
  end;
  YamlDocumentParser = class
  public
    class function Create(const Input: IYamlInput): IYamlDocumentParser;
  end;

  (** @} *)

  (**
   * @defgroup emitter Emitter Definitions
   * @{
   *)

  (**
   * The prototype of a write handler.
   *
   * The write handler is called when the emitter needs to flush the accumulated
   * characters to the output.  The handler should write @a size bytes of the
   * @a buffer to the output.
   *
   * @param[in,out]   data        A pointer to an application data specified by
   *                              yaml_emitter_set_output().
   * @param[in]       buffer      The buffer with bytes to be written.
   * @param[in]       size        The size of the buffer.
   *
   * @returns On success, the handler should return @c 1.  If the handler failed,
   * the returned value should be @c 0.
   *)

  IYamlOutput = interface
  ['{C92FFC27-2B7C-4D4C-8772-22D92E636AF9}']
    procedure Write(const Buffer; Size: Integer);
    function GetEncoding: TYamlEncoding;
    property Encoding: TYamlEncoding read GetEncoding;
  end;

  (** The emitter states. *)
  // yaml_emitter_state_t

  (**
   * The emitter structure.
   *
   * All members are internal.  Manage the structure using the @c yaml_emitter_
   * family of functions.
   *)

  // yaml_emitter_t

  (**
   * Initialize an emitter.
   *
   * This function creates a new emitter object.  An application is responsible
   * for destroying the object using the yaml_emitter_delete() function.
   *
   * @param[out]      emitter     An empty parser object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  // yaml_emitter_initialize

  (**
   * Destroy an emitter.
   *
   * @param[in,out]   emitter     An emitter object.
   *)

  // yaml_emitter_delete

  (**
   * Set a string output.
   *
   * The emitter will write the output characters to the @a output buffer of the
   * size @a size.  The emitter will set @a size_written to the number of written
   * bytes.  If the buffer is smaller than required, the emitter produces the
   * YAML_WRITE_ERROR error.
   *
   * @param[in,out]   emitter         An emitter object.
   * @param[in]       output          An output buffer.
   * @param[in]       size            The buffer size.
   * @param[in]       size_written    The pointer to save the number of written
   *                                  bytes.
   *)

  IYamlOutputBuffer = interface(IYamlOutput)
  ['{AFA9CE76-A93D-4F4A-BAE5-91263B7A091D}']
    function GetSize: Integer;
    function GetSizeWritten: Integer;
    function GetValue: YamlString;
    property Size: Integer read GetSize;
    property SizeWritten: Integer read GetSizeWritten;
    property Value: YamlString read GetValue;
  end;
  YamlOutput = class
  public
    class function Create(Output: Pointer; Size: Integer; Encoding: TYamlEncoding): IYamlOutput; overload;
    class function Create(SizeInWideChars: Integer): IYamlOutputBuffer; overload;

  (**
   * Set a file output.
   *
   * @a file should be a file object open for writing.  The application is
   * responsible for closing the @a file.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       file        An open file.
   *)

    class function Create(Output: TStream; Encoding: TYamlEncoding): IYamlOutput; overload;
  end;

  (**
   * Set a generic output handler.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       handler     A write handler.
   * @param[in]       data        Any application data for passing to the write
   *                              handler.
   *)

  // yaml_emitter_set_output

  (**
   * Set the output encoding.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       encoding    The output encoding.
   *)

  // _yaml_emitter_set_encoding

  (**
   * Set if the output should be in the "canonical" format as in the YAML
   * specification.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       canonical   If the output is canonical.
   *)

  IYamlEmitterSettings = interface
  ['{DE9B01DC-5FED-41EE-89DC-ADAC0F5207A6}']
    function SetCanonical(Canonical: Boolean): IYamlEmitterSettings;

  (**
   * Set the intendation increment.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       indent      The indentation increment (1 < . < 10).
   *)

    function SetIndent(Indent: Integer): IYamlEmitterSettings;

  (**
   * Set the preferred line width. @c -1 means unlimited.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       width       The preferred line width.
   *)

    function SetWidth(Width: Integer): IYamlEmitterSettings;

  (**
   * Set if unescaped non-ASCII characters are allowed.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       unicode     If unescaped Unicode characters are allowed.
   *)

    function SetUnicode(Unicode: Boolean): IYamlEmitterSettings;

  (**
   * Set the preferred line break.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in]       line_break  The preferred line break.
   *)

    function SetLineBreak(LineBreak: TYamlBreak): IYamlEmitterSettings;
    function GetCanonical: Boolean;
    function GetIndent: Integer;
    function GetWidth: Integer;
    function GetUnicode: Boolean;
    function GetLineBreak: TYamlBreak;
    property Canonical: Boolean read GetCanonical;
    property Indent: Integer read GetIndent;
    property Width: Integer read GetWidth;
    property Unicode: Boolean read GetUnicode;
    property LineBreak: TYamlBreak read GetLineBreak;
  end;

  (**
   * Emit an event.
   *
   * The event object may be generated using the yaml_parser_parse() function.
   * The emitter takes the responsibility for the event object and destroys its
   * content after it is emitted. The event object is destroyed even if the
   * function fails.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in,out]   event       An event object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  IYamlEventEmitter = interface
  ['{5EB9D30F-C05B-4834-9565-7527B24E655D}']
    procedure Emit(var Event: IYamlEvent);
    procedure Flush;
  end;
  YamlEventEmitter = class
  public
    class function Create(const Output: IYamlOutput;
      const Settings: IYamlEmitterSettings = nil): IYamlEventEmitter;
    class function Settings: IYamlEmitterSettings;
  end;

  (**
   * Start a YAML stream.
   *
   * This function should be used before yaml_emitter_dump() is called.
   *
   * @param[in,out]   emitter     An emitter object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

  IYamlDocumentEmitter = interface
  ['{67096033-CD73-4971-AA53-B418A7AE4FFF}']
    procedure Open;

  (**
   * Finish a YAML stream.
   *
   * This function should be used after yaml_emitter_dump() is called.
   *
   * @param[in,out]   emitter     An emitter object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

    procedure Close;

  (**
   * Emit a YAML document.
   *
   * The documen object may be generated using the yaml_parser_load() function
   * or the yaml_document_initialize() function.  The emitter takes the
   * responsibility for the document object and destoys its content after
   * it is emitted. The document object is destroyedeven if the function fails.
   *
   * @param[in,out]   emitter     An emitter object.
   * @param[in,out]   document    A document object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

    procedure Dump(var Document: IYamlDocument);

  (**
   * Flush the accumulated characters to the output.
   *
   * @param[in,out]   emitter     An emitter object.
   *
   * @returns @c 1 if the function succeeded, @c 0 on error.
   *)

    procedure Flush;
  end;
  YamlDocumentEmitter = class
  public
    class function Create(const Output: IYamlOutput;
      const Settings: IYamlEmitterSettings = nil): IYamlDocumentEmitter;
    class function Settings: IYamlEmitterSettings;
  end;

  (** @} *)

implementation

uses
  WideStrUtils; // WStrLen

// TODO: Document subnodes: array of interface -> interface
// TODO: ScalarAnchor, MappingAnchor, ... -> Anchor


type
  TYamlVersionImpl = class(TInterfacedObject, IYamlVersion)
  public
    function GetAsString: UnicodeString;
    function GetMajor: Integer;
    function GetMinor: Integer;
    function GetPatch: Integer;
    property AsString: UnicodeString read GetAsString;
    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
    property Patch: Integer read GetPatch;
  end;

function YamlVersion: IYamlVersion;
begin
  Result := TYamlVersionImpl.Create;
end;

function TYamlVersionImpl.GetAsString: UnicodeString;
begin
  Result := UTF8ToUnicodeString(_yaml_get_version_string);
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

type
  TYamlVersionDirectiveImpl = class(TInterfacedObject, IYamlVersionDirective)
  private
    FVersionDirective: TYamlVersionDirective;
  public
    constructor Create(Major, Minor: Integer); overload;
    constructor Create(VersionDirective: PYamlVersionDirective); overload;
    constructor Create(const VersionDirective: IYamlVersionDirective); overload;
    function GetMajor: Integer;
    function GetMinor: Integer;
    property Major: Integer read GetMajor;
    property Minor: Integer read GetMinor;
  end;

constructor TYamlVersionDirectiveImpl.Create(Major, Minor: Integer);
begin
  inherited Create;
  FVersionDirective.major := Major;
  FVersionDirective.minor := Minor;
end;

constructor TYamlVersionDirectiveImpl.Create(VersionDirective: PYamlVersionDirective);
begin
  if not Assigned(VersionDirective) then
    raise ERangeError.Create('TYamlVersionDirectiveImpl.Create(PYamlVersionDirective): VersionDirective = nil');
  Create(VersionDirective.major,VersionDirective.minor);
end;

constructor TYamlVersionDirectiveImpl.Create(const VersionDirective: IYamlVersionDirective);
begin
  if not Assigned(VersionDirective) then
    raise ERangeError.Create('TYamlVersionDirectiveImpl.Create(IYamlVersionDirective): VersionDirective = nil');
  Create(VersionDirective.Major,VersionDirective.Minor);
end;

class function YamlVersionDirective.Create(Major, Minor: Integer): IYamlVersionDirective;
begin
  Result := TYamlVersionDirectiveImpl.Create(Major, Minor);
end;

function TYamlVersionDirectiveImpl.GetMajor: Integer;
begin
  Result := FVersionDirective.major;
end;

function TYamlVersionDirectiveImpl.GetMinor: Integer;
begin
  Result := FVersionDirective.minor;
end;

type
  TYamlTagDirectiveImpl = class(TInterfacedObject, IYamlTagDirective)
  private
    FHandle, FPrefix: YamlString;
  public
    constructor Create(const Handle, Prefix: YamlString); overload;
    constructor Create(TagDirective: PYamlTagDirective); overload;
    constructor Create(const TagDirective: IYamlTagDirective); overload;
    function GetHandle: YamlString;
    function GetPrefix: YamlString;
    property Handle: YamlString read GetHandle;
    property Prefix: YamlString read GetPrefix;
  end;

constructor TYamlTagDirectiveImpl.Create(const Handle, Prefix: YamlString);
begin
  inherited Create;
  FHandle := Handle;
  FPrefix := Prefix;
end;

constructor TYamlTagDirectiveImpl.Create(TagDirective: PYamlTagDirective);
begin
  if not Assigned(TagDirective) then
    raise ERangeError.Create('TYamlTagDirectiveImpl.Create(PYamlTagDirective): TagDirective = nil');
  inherited Create;
  FHandle := UTF8ToUnicodeString(TagDirective.handle);
  FPrefix := UTF8ToUnicodeString(TagDirective.prefix);
end;

constructor TYamlTagDirectiveImpl.Create(const TagDirective: IYamlTagDirective);
begin
  if not Assigned(TagDirective) then
    raise ERangeError.Create('TYamlTagDirectiveImpl.Create(IYamlTagDirective): TagDirective = nil');
  Create(TagDirective.Handle, TagDirective.Prefix);
end;

class function YamlTagDirective.Create(const Handle, Prefix: YamlString): IYamlTagDirective;
begin
  Result := TYamlTagDirectiveImpl.Create(Handle, Prefix);
end;

function TYamlTagDirectiveImpl.GetHandle: YamlString;
begin
  Result := FHandle;
end;

function TYamlTagDirectiveImpl.GetPrefix: YamlString;
begin
  Result := FPrefix;
end;

constructor EYamlReaderError.Create(const Problem: YamlString; ProblemValue, ProblemOffset: Integer);
begin
  if ProblemValue <> -1 then
    inherited CreateFmt('Reader error: %s: #%x at %d', [Problem, ProblemValue, ProblemOffset])
  else
    inherited CreateFmt('Reader error: %s at %d', [Problem, ProblemOffset]);
  FProblem := Problem;
  FProblemValue := ProblemValue;
  FProblemOffset := ProblemOffset;
end;

constructor EYamlScannerError.Create(const Context: YamlString; const ContextMark: IYamlMark;
  const Problem: YamlString; const ProblemMark: IYamlMark);
begin
  if Context <> '' then
    inherited CreateFmt('Scanner error: %s at line %d, column %d'#13#10 +
      '%s at line %d, column %d',
      [Context, ContextMark.Line + 1, ContextMark.Column + 1,
        Problem, ProblemMark.Line + 1, ProblemMark.Column + 1])
  else
    inherited CreateFmt('Scanner error: %s at line %d, column %d',
      [Problem, ProblemMark.Line + 1, ProblemMark.Column + 1]);
  FContext := Context;
  FContextMark := ContextMark;
  FProblem := Problem;
  FProblemMark := ProblemMark;
end;

constructor EYamlParserError.Create(const Problem: YamlString; const ProblemMark: IYamlMark);
begin
  inherited CreateFmt('Parser error: %s at line %d, column %d',
    [Problem, ProblemMark.Line + 1, ProblemMark.Column + 1]);
  FProblem := Problem;
  FProblemMark := ProblemMark;
end;

constructor EYamlComposerError.Create(const Context: YamlString; const ContextMark: IYamlMark;
  const Problem: YamlString; const ProblemMark: IYamlMark);
begin
  if Context <> '' then
    inherited CreateFmt('Composer error: %s at line %d, column %d'#13#10 +
      '%s at line %d, column %d',
      [Context, ContextMark.Line + 1, ContextMark.Column + 1,
        Problem, ProblemMark.Line + 1, ProblemMark.Column + 1])
  else
    inherited CreateFmt('Composer error: %s at line %d, column %d',
      [Problem, ProblemMark.Line + 1, ProblemMark.Column + 1]);
  FContext := Context;
  FContextMark := ContextMark;
  FProblem := Problem;
  FProblemMark := ProblemMark;
end;

constructor EYamlConstructorError.Create(const Context: YamlString; const ContextMark: IYamlMark;
  const Problem: YamlString; const ProblemMark: IYamlMark);
begin
  if Context <> '' then
    inherited CreateFmt('Constructor error: %s at line %d, column %d'#13#10 +
      '%s at line %d, column %d',
      [Context, ContextMark.Line + 1, ContextMark.Column + 1,
        Problem, ProblemMark.Line + 1, ProblemMark.Column + 1])
  else
    inherited CreateFmt('Constructor error: %s at line %d, column %d',
      [Problem, ProblemMark.Line + 1, ProblemMark.Column + 1]);
  FContext := Context;
  FContextMark := ContextMark;
  FProblem := Problem;
  FProblemMark := ProblemMark;
end;

constructor EYamlWriterError.Create(const Problem: YamlString);
begin
  inherited CreateFmt('Writer error: %s', [Problem]);
  FProblem := Problem;
end;

constructor EYamlEmitterError.Create(const Problem: YamlString);
begin
  inherited CreateFmt('Emitter error: %s', [Problem]);
  FProblem := Problem;
end;

constructor EYamlRepresenterError.Create(const Problem: YamlString);
begin
  inherited CreateFmt('Representer error: %s', [Problem]);
  FProblem := Problem;
end;

type
  TYamlMarkImpl = class(TInterfacedObject, IYamlMark)
  private
    FMark: TYamlMark;
  public
    constructor Create(Index, Line, Column: Integer); overload;
    constructor Create(Mark: PYamlMark); overload;
    constructor Create(const Mark: IYamlMark); overload;
    function GetIndex: Integer;
    function GetLine: Integer;
    function GetColumn: Integer;
    property Index: Integer read GetIndex;
    property Line: Integer read GetLine;
    property Column: Integer read GetColumn;
  end;

constructor TYamlMarkImpl.Create(Index, Line, Column: Integer);
begin
  inherited Create;
  FMark.index := Index;
  FMark.line := Line;
  FMark.column := Column;
end;

constructor TYamlMarkImpl.Create(Mark: PYamlMark);
begin
  if not Assigned(Mark) then
    raise ERangeError.Create('TYamlMarkImpl.Create(PYamlMark): Mark = nil');
  Create(Mark.index, Mark.line, Mark.column);
end;

constructor TYamlMarkImpl.Create(const Mark: IYamlMark);
begin
  if not Assigned(Mark) then
    raise ERangeError.Create('TYamlMarkImpl.Create(IYamlMark): Mark = nil');
  Create(Mark.Index, Mark.Line, Mark.Column);
end;

function TYamlMarkImpl.GetIndex: Integer;
begin
  Result := FMark.index;
end;

function TYamlMarkImpl.GetLine: Integer;
begin
  Result := FMark.line;
end;

function TYamlMarkImpl.GetColumn: Integer;
begin
  Result := FMark.column;
end;

type
  TYamlTokenImpl = class(TInterfacedObject, IYamlToken)
  private
    FToken: TYamlToken;
  public
    constructor Create(out Token: PYamlToken);
    destructor Destroy; override;
    function GetTokenType: TYamlTokenType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetAliasValue: YamlString;
    function GetAnchorValue: YamlString;
    function GetTagHandle: YamlString;
    function GetTagSuffix: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirective: IYamlTagDirective;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    property TokenType: TYamlTokenType read GetTokenType;
    property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;
    property AliasValue: YamlString read GetAliasValue;
    property AnchorValue: YamlString read GetAnchorValue;
    property TagHandle: YamlString read GetTagHandle;
    property TagSuffix: YamlString read GetTagSuffix;
    property ScalarValue: YamlString read GetScalarValue;
    property ScalarStyle: TYamlScalarStyle read GetScalarStyle;
    property VersionDirective: IYamlVersionDirective read GetVersionDirective;
    property TagDirective: IYamlTagDirective read GetTagDirective;
    property StartMark: IYamlMark read GetStartMark;
    property EndMark: IYamlMark read GetEndMark;
  end;

constructor TYamlTokenImpl.Create(out Token: PYamlToken);
begin
  inherited Create;
  Token := @FToken;
end;

destructor TYamlTokenImpl.Destroy;
begin
  _yaml_token_delete(@FToken);
  inherited Destroy;
end;

function TYamlTokenImpl.GetTokenType: TYamlTokenType;
begin
  Result := FToken.data.type_;
end;

function TYamlTokenImpl.GetStreamStartEncoding: TYamlEncoding;
begin
  if FToken.data.type_ <> yamlStreamStartToken then
    raise ERangeError.Create('YamlToken.StreamStartEncoding: TokenType <> yamlStreamStartToken');
  Result := FToken.data.stream_start_encoding;
end;

function TYamlTokenImpl.GetAliasValue: YamlString;
begin
  if FToken.data.type_ <> yamlAliasToken then
    raise ERangeError.Create('YamlToken.AliasValue: TokenType <> yamlAliasToken');
  Result := UTF8ToUnicodeString(FToken.data.alias_value);
end;

function TYamlTokenImpl.GetAnchorValue: YamlString;
begin
  if FToken.data.type_ <> yamlAnchorToken then
    raise ERangeError.Create('YamlToken.AnchorValue: TokenType <> yamlAnchorToken');
  Result := UTF8ToUnicodeString(FToken.data.anchor_value);
end;

function TYamlTokenImpl.GetTagHandle: YamlString;
begin
  if FToken.data.type_ <> yamlTagToken then
    raise ERangeError.Create('YamlToken.TagHandle: TokenType <> yamlTagToken');
  Result := UTF8ToUnicodeString(FToken.data.tag_handle);
end;

function TYamlTokenImpl.GetTagSuffix: YamlString;
begin
  if FToken.data.type_ <> yamlTagToken then
    raise ERangeError.Create('YamlToken.TagSuffix: TokenType <> yamlTagToken');
  Result := UTF8ToUnicodeString(FToken.data.tag_suffix);
end;

function TYamlTokenImpl.GetScalarValue: YamlString;
var
  Temp: UTF8String;
begin
  if FToken.data.type_ <> yamlScalarToken then
    raise ERangeError.Create('YamlToken.ScalarValue: TokenType <> yamlScalarToken');
  if Assigned(FToken.data.scalar_value) then
    SetString(Temp, FToken.data.scalar_value, FToken.data.scalar_length);
  Result := UTF8ToUnicodeString(Temp);
end;

function TYamlTokenImpl.GetScalarStyle: TYamlScalarStyle;
begin
  if FToken.data.type_ <> yamlScalarToken then
    raise ERangeError.Create('YamlToken.ScalarStyle: TokenType <> yamlScalarToken');
  Result := FToken.data.scalar_style;
end;

function TYamlTokenImpl.GetVersionDirective: IYamlVersionDirective;
begin
  if FToken.data.type_ <> yamlVersionDirectiveToken then
    raise ERangeError.Create('YamlToken.VersionDirective: TokenType <> yamlVersionDirectiveToken');
  Result := YamlVersionDirective.Create(FToken.data.version_directive_major, FToken.data.version_directive_minor);
end;

function TYamlTokenImpl.GetTagDirective: IYamlTagDirective;
var
  Temp: TYamlTagDirective;
begin
  if FToken.data.type_ <> yamlTagDirectiveToken then
    raise ERangeError.Create('YamlToken.TagDirective: TokenType <> yamlTagDirectiveToken');
  Temp.handle := FToken.data.tag_directive_handle;
  Temp.prefix := FToken.data.tag_directive_prefix;
  Result := TYamlTagDirectiveImpl.Create(@Temp);
end;

function TYamlTokenImpl.GetStartMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FToken.start_mark));
end;

function TYamlTokenImpl.GetEndMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FToken.end_mark));
end;

type
  IYamlEventImpl = interface
  ['{456ADABA-5C5B-4F69-B8F4-3882DDA8D81A}']
    function GetYamlEvent: PYamlEvent;
    property YamlEvent: PYamlEvent read GetYamlEvent;
  end;

  TYamlEventImpl = class(TInterfacedObject, IYamlEvent, IYamlEventImpl)
  private
    FEvent: TYamlEvent;
  public
    constructor Create(out Event: PYamlEvent);
    destructor Destroy; override;
    function GetEventType: TYamlEventType;
    function GetStreamStartEncoding: TYamlEncoding;
    function GetDocumentStartVersionDirective: IYamlVersionDirective;
    function GetDocumentStartTagDirectives: TIYamlTagDirectiveDynArray;
    function GetDocumentStartImplicit: Boolean;
    function GetDocumentEndImplicit: Boolean;
    function GetAliasAnchor: YamlString;
    function GetScalarAnchor: YamlString;
    function GetScalarTag: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarPlainImplicit: Boolean;
    function GetScalarQuotedImplicit: Boolean;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceStartAnchor: YamlString;
    function GetSequenceStartTag: YamlString;
    function GetSequenceStartImplicit: Boolean;
    function GetSequenceStartStyle: TYamlSequenceStyle;
    function GetMappingStartAnchor: YamlString;
    function GetMappingStartTag: YamlString;
    function GetMappingStartImplicit: Boolean;
    function GetMappingStartStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;
    function GetYamlEvent: PYamlEvent;

    property EventType: TYamlEventType read GetEventType;
    property StreamStartEncoding: TYamlEncoding read GetStreamStartEncoding;
    property DocumentStartVersionDirective: IYamlVersionDirective read GetDocumentStartVersionDirective;
    property DocumentStartTagDirectives: TIYamlTagDirectiveDynArray read GetDocumentStartTagDirectives;
    property DocumentStartImplicit: Boolean read GetDocumentStartImplicit;
    property DocumentEndImplicit: Boolean read GetDocumentEndImplicit;
    property AliasAnchor: YamlString read GetAliasAnchor;
    property ScalarAnchor: YamlString read GetScalarAnchor;
    property ScalarTag: YamlString read GetScalarTag;
    property ScalarValue: YamlString read GetScalarValue;
    property ScalarPlainImplicit: Boolean read GetScalarPlainImplicit;
    property ScalarQuotedImplicit: Boolean read GetScalarQuotedImplicit;
    property ScalarStyle: TYamlScalarStyle read GetScalarStyle;
    property SequenceStartAnchor: YamlString read GetSequenceStartAnchor;
    property SequenceStartTag: YamlString read GetSequenceStartTag;
    property SequenceStartImplicit: Boolean read GetSequenceStartImplicit;
    property SequenceStartStyle: TYamlSequenceStyle read GetSequenceStartStyle;
    property MappingStartAnchor: YamlString read GetMappingStartAnchor;
    property MappingStartTag: YamlString read GetMappingStartTag;
    property MappingStartImplicit: Boolean read GetMappingStartImplicit;
    property MappingStartStyle: TYamlMappingStyle read GetMappingStartStyle;
    property StartMark: IYamlMark read GetStartMark;
    property EndMark: IYamlMark read GetEndMark;
    property YamlEvent: PYamlEvent read GetYamlEvent;
  end;

constructor TYamlEventImpl.Create(out Event: PYamlEvent);
begin
  inherited Create;
  Event := @FEvent;
end;

destructor TYamlEventImpl.Destroy;
begin
  _yaml_event_delete(FEvent);
  inherited Destroy;
end;

function TYamlEventImpl.GetEventType: TYamlEventType;
begin
  Result := FEvent.data.type_;
end;

function TYamlEventImpl.GetStreamStartEncoding: TYamlEncoding;
begin
  if FEvent.data.type_ <> yamlStreamStartEvent then
    raise ERangeError.Create('YamlEvent.StreamStartEncoding: EventType <> yamlStreamStartToken');
  Result := FEvent.data.stream_start_encoding;
end;

function TYamlEventImpl.GetDocumentStartVersionDirective: IYamlVersionDirective;
begin
  if FEvent.data.type_ <> yamlDocumentStartEvent then
    raise ERangeError.Create('YamlEvent.DocumentStartVersionDirective: EventType <> yamlDocumentStartEvent');
  Result := TYamlVersionDirectiveImpl.Create(FEvent.data.document_start_version_directive);
end;

function TYamlEventImpl.GetDocumentStartTagDirectives: TIYamlTagDirectiveDynArray;
var
  Start, Finish: PAnsiChar;
  i, L: Integer;
begin
  if FEvent.data.type_ <> yamlDocumentStartEvent then
    raise ERangeError.Create('YamlEvent.DocumentStartTagDirectives: EventType <> yamlDocumentStartEvent');
  Start := PAnsiChar(Pointer(FEvent.data.document_start_tag_directives_start));
  Finish := PAnsiChar(Pointer(FEvent.data.document_start_tag_directives_start));
  L := (Finish - Start) div SizeOf(TYamlTagDirective);
  for i := 0 to L - 1 do
  begin
    Result[i] := TYamlTagDirectiveImpl.Create(PYamlTagDirective(Pointer(Start + i * SizeOf(TYamlTagDirective))));
  end;
end;

function TYamlEventImpl.GetDocumentStartImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlDocumentStartEvent then
    raise ERangeError.Create('YamlEvent.DocumentStartImplicit: EventType <> yamlDocumentStartEvent');
  Result := FEvent.data.document_start_implicit <> 0;
end;

function TYamlEventImpl.GetDocumentEndImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlDocumentEndEvent then
    raise ERangeError.Create('YamlEvent.DocumentEndImplicit: EventType <> yamlDocumentEndEvent');
  Result := FEvent.data.document_end_implicit <> 0;
end;

function TYamlEventImpl.GetAliasAnchor: YamlString;
begin
  if FEvent.data.type_ <> yamlAliasEvent then
    raise ERangeError.Create('YamlEvent.AliasAnchor: EventType <> yamlAliasEvent');
  Result := UTF8ToUnicodeString(FEvent.data.alias_anchor);
end;

function TYamlEventImpl.GetScalarAnchor: YamlString;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarAnchor: EventType <> yamlScalarEvent');
  Result := UTF8ToUnicodeString(FEvent.data.scalar_anchor);
end;

function TYamlEventImpl.GetScalarTag: YamlString;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarTag: EventType <> yamlScalarEvent');
  Result := UTF8ToUnicodeString(FEvent.data.scalar_tag);
end;

function TYamlEventImpl.GetScalarValue: YamlString;
var
  Temp: UTF8String;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarTag: EventType <> yamlScalarEvent');
  if Assigned(FEvent.data.scalar_value) then
    SetString(Temp, FEvent.data.scalar_value, FEvent.data.scalar_length);
  Result := UTF8ToUnicodeString(Temp);
end;

function TYamlEventImpl.GetScalarPlainImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarPlainImplicit: EventType <> yamlScalarEvent');
  Result := FEvent.data.scalar_plain_implicit <> 0;
end;

function TYamlEventImpl.GetScalarQuotedImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarQuotedImplicit: EventType <> yamlScalarEvent');
  Result := FEvent.data.scalar_quoted_implicit <> 0;
end;

function TYamlEventImpl.GetScalarStyle: TYamlScalarStyle;
begin
  if FEvent.data.type_ <> yamlScalarEvent then
    raise ERangeError.Create('YamlEvent.ScalarStyle: EventType <> yamlScalarEvent');
  Result := FEvent.data.scalar_style;
end;

function TYamlEventImpl.GetSequenceStartAnchor: YamlString;
begin
  if FEvent.data.type_ <> yamlSequenceStartEvent then
    raise ERangeError.Create('YamlEvent.SequenceStartAnchor: EventType <> yamlSequenceStartEvent');
  Result := UTF8ToUnicodeString(FEvent.data.sequence_start_anchor);
end;

function TYamlEventImpl.GetSequenceStartTag: YamlString;
begin
  if FEvent.data.type_ <> yamlSequenceStartEvent then
    raise ERangeError.Create('YamlEvent.SequenceStartTag: EventType <> yamlSequenceStartEvent');
  Result := UTF8ToUnicodeString(FEvent.data.sequence_start_tag);
end;

function TYamlEventImpl.GetSequenceStartImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlSequenceStartEvent then
    raise ERangeError.Create('YamlEvent.SequenceStartImplicit: EventType <> yamlSequenceStartEvent');
  Result := FEvent.data.sequence_start_implicit <> 0;
end;

function TYamlEventImpl.GetSequenceStartStyle: TYamlSequenceStyle;
begin
  if FEvent.data.type_ <> yamlSequenceStartEvent then
    raise ERangeError.Create('YamlEvent.SequenceStartStyle: EventType <> yamlSequenceStartEvent');
  Result := FEvent.data.sequence_start_style;
end;

function TYamlEventImpl.GetMappingStartAnchor: YamlString;
begin
  if FEvent.data.type_ <> yamlMappingStartEvent then
    raise ERangeError.Create('YamlEvent.MappingStartAnchor: EventType <> yamlMappingStartEvent');
  Result := UTF8ToUnicodeString(FEvent.data.mapping_start_anchor);
end;

function TYamlEventImpl.GetMappingStartTag: YamlString;
begin
  if FEvent.data.type_ <> yamlMappingStartEvent then
    raise ERangeError.Create('YamlEvent.MappingStartTag: EventType <> yamlMappingStartEvent');
  Result := UTF8ToUnicodeString(FEvent.data.mapping_start_tag);
end;

function TYamlEventImpl.GetMappingStartImplicit: Boolean;
begin
  if FEvent.data.type_ <> yamlMappingStartEvent then
    raise ERangeError.Create('YamlEvent.MappingStartImplicit: EventType <> yamlMappingStartEvent');
  Result := FEvent.data.mapping_start_implicit <> 0;
end;

function TYamlEventImpl.GetMappingStartStyle: TYamlMappingStyle;
begin
  if FEvent.data.type_ <> yamlMappingStartEvent then
    raise ERangeError.Create('YamlEvent.MappingStartStyle: EventType <> yamlMappingStartEvent');
  Result := FEvent.data.mapping_start_style;
end;

function TYamlEventImpl.GetStartMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FEvent.start_mark));
end;

function TYamlEventImpl.GetEndMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FEvent.end_mark));
end;

function TYamlEventImpl.GetYamlEvent: PYamlEvent;
begin
  Result := @FEvent;
end;

class function YamlEventStreamStart.Create(Encoding: TYamlEncoding): IYamlEvent;
var
  NewEvent: PYamlEvent;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_stream_start_event_initialize(NewEvent^, Encoding) = 0 then
    raise EYamlMemoryError.Create('YamlEventStreamStart.Create: out of memory');
end;

class function YamlEventStreamEnd.Create: IYamlEvent;
var
  NewEvent: PYamlEvent;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_stream_end_event_initialize(NewEvent^) = 0 then
    raise EYamlMemoryError.Create('YamlEventStreamEnd.Create: out of memory');
end;

class function YamlEventDocumentStart.Create(const VersionDirective: IYamlVersionDirective;
  const TagDirectives: array of IYamlTagDirective; Implicit: Boolean): IYamlEvent;
var
  NewEvent: PYamlEvent;
  InternalVersionDirective: TYamlVersionDirective;
  InternalVersionDirectivePtr: PYamlVersionDirective;
  InternalTagDirectives: array of TYamlTagDirective;
  InternalTagDirectivesStr: array of UTF8String;
  InternalTagDirectiveStart, InternalTagDirectiveEnd: PYamlTagDirective;
  i, j, L: Integer;
begin
  InternalVersionDirectivePtr := nil;
  if Assigned(VersionDirective) then
  begin
    InternalVersionDirective.major := VersionDirective.Major;
    InternalVersionDirective.minor := VersionDirective.Minor;
    InternalVersionDirectivePtr := @InternalVersionDirective;
  end;

  InternalTagDirectiveStart := nil;
  InternalTagDirectiveEnd := nil;
  L := Length(TagDirectives);
  if L <> 0 then
  begin
    SetLength(InternalTagDirectives, L + 1);
    SetLength(InternalTagDirectivesStr, L * 2);
    j := 0;
    for i := 0 to L - 1 do
      if Assigned(TagDirectives[i]) then
      begin
        InternalTagDirectivesStr[j * 2] := UTF8Encode(TagDirectives[i].Handle);
        InternalTagDirectivesStr[j * 2 + 1] := UTF8Encode(TagDirectives[i].Prefix);
        InternalTagDirectives[j].handle := PYamlChar(InternalTagDirectivesStr[j * 2]);
        InternalTagDirectives[j].prefix := PYamlChar(InternalTagDirectivesStr[j * 2 + 1]);
        Inc(j);
      end;
    InternalTagDirectiveStart := @(InternalTagDirectives[0]);
    InternalTagDirectiveEnd := @(InternalTagDirectives[j]);
  end;

  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_document_start_event_initialize(NewEvent^,
    InternalVersionDirectivePtr,
    InternalTagDirectiveStart,
    InternalTagDirectiveEnd,
    Integer(Implicit)) = 0 then
    raise EYamlMemoryError.Create('YamlEventDocumentStart.Create: out of memory');
end;

class function YamlEventDocumentEnd.Create(Implicit: Boolean): IYamlEvent;
var
  NewEvent: PYamlEvent;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_document_end_event_initialize(NewEvent^, Integer(Implicit)) = 0 then
    raise EYamlMemoryError.Create('YamlEventDocumentEnd.Create: out of memory');
end;

class function YamlEventAlias.Create(const Anchor: YamlString): IYamlEvent;
var
  NewEvent: PYamlEvent;
  InternalAnchor: UTF8String;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  InternalAnchor := UTF8Encode(Anchor);
  if _yaml_alias_event_initialize(NewEvent^, PYamlChar(InternalAnchor)) = 0 then
    raise EYamlMemoryError.Create('YamlEventAlias.Create: out of memory');
end;

class function YamlEventScalar.Create(const Anchor, Tag, Value: YamlString;
  PlainImplicit, QuotedImplicit: Boolean;
  Style: TYamlScalarStyle): IYamlEvent;
var
  NewEvent: PYamlEvent;
  InternalAnchor, InternalTag, InternalValue: UTF8String;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  InternalAnchor := UTF8Encode(Anchor);
  InternalTag := UTF8Encode(Tag);
  InternalValue := UTF8Encode(Value);
  if _yaml_scalar_event_initialize(NewEvent^,
    PYamlChar(Pointer(InternalAnchor)), PYamlChar(Pointer(InternalTag)),
    PYamlChar(InternalValue), Length(InternalValue),
    Integer(PlainImplicit), Integer(QuotedImplicit),
    Style) = 0 then
    raise EYamlMemoryError.Create('YamlEventScalar.Create: out of memory');
end;

class function YamlEventSequenceStart.Create(const Anchor, Tag: YamlString;
  Implicit: Boolean; Style: TYamlSequenceStyle): IYamlEvent;
var
  NewEvent: PYamlEvent;
  InternalAnchor, InternalTag: UTF8String;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  InternalAnchor := UTF8Encode(Anchor);
  InternalTag := UTF8Encode(Tag);
  if _yaml_sequence_start_event_initialize(NewEvent^,
    PYamlChar(Pointer(InternalAnchor)), PYamlChar(Pointer(InternalTag)),
    Integer(Implicit), Style) = 0 then
    raise EYamlMemoryError.Create('YamlEventSequenceStart.Create: out of memory');
end;

class function YamlEventSequenceEnd.Create: IYamlEvent;
var
  NewEvent: PYamlEvent;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_sequence_end_event_initialize(NewEvent^) = 0 then
    raise EYamlMemoryError.Create('YamlEventSequenceEnd.Create: out of memory');
end;

class function YamlEventMappingStart.Create(const Anchor, Tag: YamlString;
  Implicit: Boolean; Style: TYamlMappingStyle): IYamlEvent;
var
  NewEvent: PYamlEvent;
  InternalAnchor, InternalTag: UTF8String;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  InternalAnchor := UTF8Encode(Anchor);
  InternalTag := UTF8Encode(Tag);
  if _yaml_mapping_start_event_initialize(NewEvent^,
    PYamlChar(Pointer(InternalAnchor)), PYamlChar(Pointer(InternalTag)),
    Integer(Implicit), Style) = 0 then
    raise EYamlMemoryError.Create('YamlEventMappingStart.Create: out of memory');
end;

class function YamlEventMappingEnd.Create: IYamlEvent;
var
  NewEvent: PYamlEvent;
begin
  Result := TYamlEventImpl.Create(NewEvent);
  if _yaml_mapping_end_event_initialize(NewEvent^) = 0 then
    raise EYamlMemoryError.Create('YamlEventMappingEnd.Create: out of memory');
end;

type
  TYamlDocumentImpl = class;
  TYamlNodeImpl = class(TInterfacedObject, IYamlNode)
  private
    FDocument: PYamlDocument;
    FDocumentInterface: IYamlDocument;
    FId: Integer;
    function GetNode: PYamlNode;
  public
    constructor Create(Document: PYamlDocument;
      DocumentInterface: IYamlDocument; Index: Integer);
    function GetDocument: IYamlDocument;
    function GetId: Integer;
    function GetNodeType: TYamlNodeType;
    function GetTag: YamlString;
    function GetScalarValue: YamlString;
    function GetScalarStyle: TYamlScalarStyle;
    function GetSequenceItems: TIYamlNodeDynArray;
    procedure AppendSequenceItem(Item: IYamlNode);
    function GetSequenceStyle: TYamlSequenceStyle;
    function GetMappingPairs: TYamlNodePairDynArray;
    procedure AppendMappingPair(Key, Value: IYamlNode);
    function GetMappingStyle: TYamlMappingStyle;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    property Document: IYamlDocument read GetDocument;
    property Id: Integer read GetId;
    property NodeType: TYamlNodeType read GetNodeType;
    property Tag: YamlString read GetTag;
    property ScalarValue: YamlString read GetScalarValue;
    property ScalarStyle: TYamlScalarStyle read GetScalarStyle;
    property SequenceItems: TIYamlNodeDynArray read GetSequenceItems;
    property SequenceStyle: TYamlSequenceStyle read GetSequenceStyle;
    property MappingPairs: TYamlNodePairDynArray read GetMappingPairs;
    property MappingStyle: TYamlMappingStyle read GetMappingStyle;
    property StartMark: IYamlMark read GetStartMark;
    property EndMark: IYamlMark read GetEndMark;
  end;

  IYamlDocumentImpl = interface
  ['{3133D4B9-3D37-4AC7-9060-E42C12980EAE}']
    function GetYamlDocument: PYamlDocument;
    property YamlDocument: PYamlDocument read GetYamlDocument;
  end;

  TYamlDocumentImpl = class(TInterfacedObject, IYamlDocument, IYamlDocumentImpl)
  private
    FDocument: TYamlDocument;
  public
    constructor Create(const VersionDirective: IYamlVersionDirective;
      const TagDirectives: array of IYamlTagDirective;
      StartImplicit, EndImplicit: Boolean); overload;
    constructor Create(out Document: PYamlDocument); overload;
    destructor Destroy; override;
    function GetNodes: TIYamlNodeDynArray;
    function GetRootNode: IYamlNode;
    function GetVersionDirective: IYamlVersionDirective;
    function GetTagDirectives: TIYamlTagDirectiveDynArray;
    function GetStartImplicit: Boolean;
    function GetEndImplicit: Boolean;
    function GetStartMark: IYamlMark;
    function GetEndMark: IYamlMark;

    function CreateScalar(const Tag, Value: YamlString; Style: TYamlScalarStyle): IYamlNode;
    function CreateSequence(const Tag: YamlString; Style: TYamlScalarStyle): IYamlNode;
    function CreateMapping(const Tag: YamlString; Style: TYamlMappingStyle): IYamlNode;

    function GetYamlDocument: PYamlDocument;

    property Nodes: TIYamlNodeDynArray read GetNodes;
    property RootNode: IYamlNode read GetRootNode;
    property VersionDirective: IYamlVersionDirective read GetVersionDirective;
    property TagDirectives: TIYamlTagDirectiveDynArray read GetTagDirectives;
    property StartImplicit: Boolean read GetStartImplicit;
    property EndImplicit: Boolean read GetEndImplicit;
    property StartMark: IYamlMark read GetStartMark;
    property EndMark: IYamlMark read GetEndMark;
    property YamlDocument: PYamlDocument read GetYamlDocument;
  end;

constructor TYamlNodeImpl.Create(Document: PYamlDocument;
  DocumentInterface: IYamlDocument; Index: Integer);
begin
  inherited Create;
  FDocument := Document;
  if not Assigned(GetNode()) then
    raise ERangeError.Create('YamlDocument.GetNode: Index out of range');
  FDocumentInterface := DocumentInterface;
  FId := Index;
end;

function TYamlNodeImpl.GetDocument: IYamlDocument;
begin
  Result := FDocumentInterface;
end;

function TYamlNodeImpl.GetId: Integer;
begin
  Result := FId;
end;

function TYamlNodeImpl.GetNode: PYamlNode;
begin
  Result := _yaml_document_get_node(FDocument, FId + 1);
end;

function TYamlNodeImpl.GetNodeType: TYamlNodeType;
begin
  Result := GetNode.type_;
end;

function TYamlNodeImpl.GetTag: YamlString;
begin
  Result := UTF8ToUnicodeString(GetNode.tag);
end;

function TYamlNodeImpl.GetScalarValue: YamlString;
var
  Node: PYamlNode;
  Temp: UTF8String;
begin
  Node := GetNode;
  if Node.type_ <> yamlScalarNode then
    raise ERangeError.Create('YamlNode.ScalarValue: NodeType <> yamlScalarNode');
  if Assigned(Node.data.scalar_value) then
    SetString(Temp, Node.data.scalar_value, Node.data.scalar_length);
  Result := UTF8ToUnicodeString(Temp);
end;

function TYamlNodeImpl.GetScalarStyle: TYamlScalarStyle;
var
  Node: PYamlNode;
begin
  Node := GetNode;
  if Node.type_ <> yamlScalarNode then
    raise ERangeError.Create('YamlNode.ScalarStyle: NodeType <> yamlScalarNode');
  Result := Node.data.scalar_style;
end;

function TYamlNodeImpl.GetSequenceItems: TIYamlNodeDynArray;
var
  Node: PYamlNode;
  i, L: Integer;
  Start, Top: PAnsiChar;
begin
  Node := GetNode;
  if Node.type_ <> yamlSequenceNode then
    raise ERangeError.Create('YamlNode.SequenceItems: NodeType <> yamlSequenceNode');
  if Node.data.sequence_items_start <> Node.data.sequence_items_top then
  begin
    Start := PAnsiChar(Node.data.sequence_items_start);
    Top := PAnsiChar(Node.data.sequence_items_top);
    L := (Top - Start) div SizeOf(YamlThin.TYamlNodeItem);
    SetLength(Result, L);
    for i := 0 to L - 1 do
    begin
      Result[i] := TYamlNodeImpl.Create(FDocument, FDocumentInterface,
        YamlThin.PYamlNodeItem(Pointer(Start + i * SizeOf(YamlThin.TYamlNodeItem)))^ - 1);
    end;
  end;
end;

procedure TYamlNodeImpl.AppendSequenceItem(Item: IYamlNode);
var
  Node: PYamlNode;
begin
  Node := GetNode;
  if Node.type_ <> yamlSequenceNode then
    raise ERangeError.Create('YamlNode.AppendSequenceItem: NodeType <> yamlSequenceNode');
  if not Assigned(Item) then
    raise ERangeError.Create('YamlNode.AppendSequenceItem: Item = nil');
  if _yaml_document_append_sequence_item(FDocument^, FId, Item.Id) = 0 then
    raise EYamlMemoryError.Create('YamlNode.AppendSequenceItem: out of memory');
end;

function TYamlNodeImpl.GetSequenceStyle: TYamlSequenceStyle;
var
  Node: PYamlNode;
begin
  Node := GetNode;
  if Node.type_ <> yamlSequenceNode then
    raise ERangeError.Create('YamlNode.SequenceStyle: NodeType <> yamlSequenceNode');
  Result := Node.data.sequence_style;
end;

function TYamlNodeImpl.GetMappingPairs: TYamlNodePairDynArray;
var
  Node: PYamlNode;
  i, L: Integer;
  Start, Top: PAnsiChar;
begin
  Node := GetNode;
  if Node.type_ <> yamlMappingNode then
    raise ERangeError.Create('YamlNode.MappingPairs: NodeType <> yamlMappingNode');
  if Node.data.mapping_pairs_start <> Node.data.mapping_pairs_top then
  begin
    Start := PAnsiChar(Node.data.mapping_pairs_start);
    Top := PAnsiChar(Node.data.mapping_pairs_top);
    L := (Top - Start) div SizeOf(YamlThin.TYamlNodePair);
    SetLength(Result, L);
    for i := 0 to L - 1 do
    begin
      Result[i].Key := TYamlNodeImpl.Create(FDocument, FDocumentInterface,
        YamlThin.PYamlNodePair(Pointer(Start + i * SizeOf(YamlThin.TYamlNodePair))).key - 1);
      Result[i].Value := TYamlNodeImpl.Create(FDocument, FDocumentInterface,
        YamlThin.PYamlNodePair(Pointer(Start + i * SizeOf(YamlThin.TYamlNodePair))).value - 1);
    end;
  end;
end;

procedure TYamlNodeImpl.AppendMappingPair(Key, Value: IYamlNode);
var
  Node: PYamlNode;
begin
  Node := GetNode;
  if Node.type_ <> yamlMappingNode then
    raise ERangeError.Create('YamlNode.AppendMappingPair: NodeType <> yamlMappingNode');
  if not Assigned(Key) then
    raise ERangeError.Create('YamlNode.AppendMappingPair: Key = nil');
  if not Assigned(Value) then
    raise ERangeError.Create('YamlNode.AppendMappingPair: Value = nil');
  if _yaml_document_append_mapping_pair(FDocument^, FId, Key.Id, Value.Id) = 0 then
    raise EYamlMemoryError.Create('YamlNode.AppendMappingPair: out of memory');
end;

function TYamlNodeImpl.GetMappingStyle: TYamlMappingStyle;
var
  Node: PYamlNode;
begin
  Node := GetNode;
  if Node.type_ <> yamlMappingNode then
    raise ERangeError.Create('YamlNode.MappingStyle: NodeType <> yamlMappingNode');
  Result := Node.data.mapping_style;
end;

function TYamlNodeImpl.GetStartMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FDocument.start_mark));
end;

function TYamlNodeImpl.GetEndMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FDocument.end_mark));
end;

constructor TYamlDocumentImpl.Create(out Document: PYamlDocument);
begin
  inherited Create;
  Document := @FDocument;
end;

constructor TYamlDocumentImpl.Create(const VersionDirective: IYamlVersionDirective;
  const TagDirectives: array of IYamlTagDirective;
  StartImplicit, EndImplicit: Boolean);
var
  InternalVersionDirective: TYamlVersionDirective;
  InternalVersionDirectivePtr: PYamlVersionDirective;
  InternalTagDirectives: array of TYamlTagDirective;
  InternalTagDirectivesStr: array of UTF8String;
  InternalTagDirectiveStart, InternalTagDirectiveEnd: PYamlTagDirective;
  i, j, L: Integer;
begin
  inherited Create;
  InternalVersionDirectivePtr := nil;
  if Assigned(VersionDirective) then
  begin
    InternalVersionDirective.major := VersionDirective.Major;
    InternalVersionDirective.minor := VersionDirective.Minor;
    InternalVersionDirectivePtr := @InternalVersionDirective;
  end;

  InternalTagDirectiveStart := nil;
  InternalTagDirectiveEnd := nil;
  L := Length(TagDirectives);
  if L <> 0 then
  begin
    SetLength(InternalTagDirectives, L + 1);
    SetLength(InternalTagDirectivesStr, L * 2);
    j := 0;
    for i := 0 to L - 1 do
      if Assigned(TagDirectives[i]) then
      begin
        InternalTagDirectivesStr[j * 2] := UTF8Encode(TagDirectives[i].Handle);
        InternalTagDirectivesStr[j * 2 + 1] := UTF8Encode(TagDirectives[i].Prefix);
        InternalTagDirectives[j].handle := PYamlChar(InternalTagDirectivesStr[j * 2]);
        InternalTagDirectives[j].prefix := PYamlChar(InternalTagDirectivesStr[j * 2 + 1]);
        Inc(j);
      end;
    InternalTagDirectiveStart := @(InternalTagDirectives[0]);
    InternalTagDirectiveEnd := @(InternalTagDirectives[j]);
  end;

  if _yaml_document_initialize(FDocument,
    InternalVersionDirectivePtr,
    InternalTagDirectiveStart,
    InternalTagDirectiveEnd,
    Integer(StartImplicit), Integer(EndImplicit)) = 0 then
    raise EYamlMemoryError.Create('YamlDocument.Create: out of memory');
end;

class function YamlDocument.Create(const VersionDirective: IYamlVersionDirective;
  const TagDirectives: array of IYamlTagDirective;
  StartImplicit, EndImplicit: Boolean): IYamlDocument;
begin
  Result := TYamlDocumentImpl.Create(VersionDirective, TagDirectives,
    StartImplicit, EndImplicit);
end;

destructor TYamlDocumentImpl.Destroy;
begin
  _yaml_document_delete(FDocument);
  inherited Destroy;
end;

function TYamlDocumentImpl.GetNodes: TIYamlNodeDynArray;
var
  i, L: Integer;
  Start, Top: PAnsiChar;
begin
  if FDocument.nodes_start <> FDocument.nodes_top then
  begin
    Start := PAnsiChar(FDocument.nodes_start);
    Top := PAnsiChar(FDocument.nodes_top);
    L := (Top - Start) div SizeOf(YamlThin.TYamlNode);
    SetLength(Result, L);
    for i := 0 to L - 1 do
    begin
      Result[i] := TYamlNodeImpl.Create(@FDocument, Self, i);
    end;
  end;
end;

function TYamlDocumentImpl.GetRootNode: IYamlNode;
begin
  if FDocument.nodes_start <> FDocument.nodes_top then
    Result := nil
  else
    Result := TYamlNodeImpl.Create(@FDocument, Self, 0);
end;

function TYamlDocumentImpl.GetVersionDirective: IYamlVersionDirective;
begin
  Result := TYamlVersionDirectiveImpl.Create(@(FDocument.version_directive));
end;

function TYamlDocumentImpl.GetTagDirectives: TIYamlTagDirectiveDynArray;
var
  Start, Finish: PAnsiChar;
  i, L: Integer;
begin
  Start := PAnsiChar(Pointer(FDocument.tag_directives_start));
  Finish := PAnsiChar(Pointer(FDocument.tag_directives_end));
  L := (Finish - Start) div SizeOf(TYamlTagDirective);
  for i := 0 to L - 1 do
  begin
    Result[i] := TYamlTagDirectiveImpl.Create(PYamlTagDirective(Pointer(Start + i * SizeOf(TYamlTagDirective))));
  end;
end;

function TYamlDocumentImpl.GetStartImplicit: Boolean;
begin
  Result := FDocument.start_implicit <> 0;
end;

function TYamlDocumentImpl.GetEndImplicit: Boolean;
begin
  Result := FDocument.end_implicit <> 0;
end;

function TYamlDocumentImpl.GetStartMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FDocument.start_mark));
end;

function TYamlDocumentImpl.GetEndMark: IYamlMark;
begin
  Result := TYamlMarkImpl.Create(@(FDocument.end_mark));
end;

function TYamlDocumentImpl.CreateScalar(const Tag, Value: YamlString; Style: TYamlScalarStyle): IYamlNode;
var
  InternalTag, InternalValue: UTF8String;
  NodeId: Integer;
begin
  InternalTag := UTF8Encode(Tag);
  InternalValue := UTF8Encode(Value);
  NodeId := _yaml_document_add_scalar(FDocument, PYamlChar(InternalTag),
    PYamlChar(InternalValue), Length(InternalValue), Style);
  if NodeId = 0 then
    raise EYamlMemoryError.Create('YamlDocument.CreateScalar: out of memory');
  Result := TYamlNodeImpl.Create(@FDocument, Self, NodeId - 1);
end;

function TYamlDocumentImpl.CreateSequence(const Tag: YamlString; Style: TYamlScalarStyle): IYamlNode;
var
  InternalTag: UTF8String;
  NodeId: Integer;
begin
  InternalTag := UTF8Encode(Tag);
  NodeId := _yaml_document_add_sequence(FDocument, PYamlChar(InternalTag),
    Style);
  if NodeId = 0 then
    raise EYamlMemoryError.Create('YamlDocument.CreateSequence: out of memory');
  Result := TYamlNodeImpl.Create(@FDocument, Self, NodeId - 1);
end;

function TYamlDocumentImpl.CreateMapping(const Tag: YamlString; Style: TYamlMappingStyle): IYamlNode;
var
  InternalTag: UTF8String;
  NodeId: Integer;
begin
  InternalTag := UTF8Encode(Tag);
  NodeId := _yaml_document_add_mapping(FDocument, PYamlChar(InternalTag),
    Style);
  if NodeId = 0 then
    raise EYamlMemoryError.Create('YamlDocument.CreateMapping: out of memory');
  Result := TYamlNodeImpl.Create(@FDocument, Self, NodeId - 1);
end;

function TYamlDocumentImpl.GetYamlDocument: PYamlDocument;
begin
  Result := @FDocument;
end;

type
  TYamlInputImpl = class(TInterfacedObject, IYamlInput)
  protected
    FEncoding: TYamlEncoding;
    constructor Create(Encoding: TYamlEncoding);
  public
    function GetIsEof: Boolean; virtual; abstract;
    function Read(var Buffer; Size: Integer): Integer; virtual; abstract;
    function GetEncoding: TYamlEncoding; virtual;
    property IsEof: Boolean read GetIsEof;
    property Encoding: TYamlEncoding read GetEncoding;
  end;

  IYamlInputMemory = interface(IInterface)
  ['{903F0B4E-3806-458A-8657-A2CD791637FC}']
    function GetMem: Pointer;
    function GetSize: Integer;
    property Mem: Pointer read GetMem;
    property Size: Integer read GetSize;
  end;

  TYamlInputMemory = class(TYamlInputImpl, IYamlInputMemory)
  protected
    FMem: Pointer;
    FSize: Integer;
    FOffset: Integer;
    constructor Create(const Mem; Size: Integer; Encoding: TYamlEncoding);
  public
    function GetIsEof: Boolean; override;
    function Read(var Buffer; Size: Integer): Integer; override;
    function GetMem: Pointer;
    function GetSize: Integer;
    property Mem: Pointer read GetMem;
    property Size: Integer read GetSize;
  end;

  TYamlInputUTF8String = class(TYamlInputMemory)
  protected
    FString: UTF8String;
  public
    constructor Create(const S: UTF8String; Encoding: TYamlEncoding);
  end;

  TYamlInputByteDynArray = class(TYamlInputMemory)
  protected
    FArray: TByteDynArray;
  public
    constructor Create(const A: TByteDynArray; Encoding: TYamlEncoding);
  end;

  IYamlInputStream = interface(IInterface)
  ['{87CAB406-13C2-4045-804F-969E6FAFEA1E}']
    function GetStream: TStream;
    property Stream: TStream read GetStream;
  end;

  TYamlInputStream = class(TYamlInputImpl, IYamlInputStream)
  protected
    FStream: TStream;
  public
    constructor Create(Stream: TStream; Encoding: TYamlEncoding);
    function GetIsEof: Boolean; override;
    function Read(var Buffer; Size: Integer): Integer; override;
    function GetStream: TStream;
    property Stream: TStream read GetStream;
  end;

constructor TYamlInputImpl.Create(Encoding: TYamlEncoding);
begin
  FEncoding := Encoding;
  inherited Create;
end;

function TYamlInputImpl.GetEncoding: TYamlEncoding;
begin
  Result := FEncoding;
end;

constructor TYamlInputMemory.Create(const Mem; Size: Integer; Encoding: TYamlEncoding);
begin
  inherited Create(Encoding);
  FMem := @Mem;
  FSize := Size;
end;

function TYamlInputMemory.GetIsEof: Boolean;
begin
  Result := FOffset >= FSize;
end;

function TYamlInputMemory.Read(var Buffer; Size: Integer): Integer;
begin
  Result := Size;
  if Size > 0 then
  begin
    if FOffset + Result > FSize then
      Result := FSize - FOffset;
    Move(FMem^, buffer, Result);
  end;
end;

function TYamlInputMemory.GetMem: Pointer;
begin
  Result := PAnsiChar(FMem) + FOffset;
end;

function TYamlInputMemory.GetSize: Integer;
begin
  Result := FSize - FOffset;
end;

constructor TYamlInputUTF8String.Create(const S: UTF8String; Encoding: TYamlEncoding);
begin
  FString := S;
  if FString <> '' then
    inherited Create(Pointer(FString)^, Length(FString), Encoding)
  else
    inherited Create(nil^, 0, Encoding);
end;

constructor TYamlInputByteDynArray.Create(const A: TByteDynArray; Encoding: TYamlEncoding);
begin
  FArray := A;
  if Length(FArray) > 0 then
    inherited Create(Pointer(FArray)^, Length(FArray), Encoding)
  else
    inherited Create(nil^, 0, Encoding);
end;

constructor TYamlInputStream.Create(Stream: TStream; Encoding: TYamlEncoding);
begin
  if not Assigned(Stream) then
    raise ERangeError.Create('YamlInput.Create: Stream = nil');
  inherited Create(Encoding);
  FStream := Stream;
end;

function TYamlInputStream.GetIsEof: Boolean;
begin
  Result := FStream.Position < FStream.Size;
end;

function TYamlInputStream.Read(var Buffer; Size: Integer): Integer;
begin
  Result := FStream.Read(Buffer, Size);
end;

function TYamlInputStream.GetStream: TStream;
begin
  Result := FStream;
end;

class function YamlInput.Create(const Input; Size: Integer; Copy: Boolean = True;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput;
var
  DummyCopy: UTF8String;
begin
  if Copy then
  begin
    SetString(DummyCopy, PAnsiChar(@Input), Size);
    Result := TYamlInputUTF8String.Create(DummyCopy, Encoding);
  end else begin
    Result := TYamlInputMemory.Create(Input, Size, Encoding);
  end;
end;

class function YamlInput.Create(Input: PAnsiChar; Size: Integer = -1; Copy: Boolean = True;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput;
begin
  if Size < 0 then
    Size := StrLen(Input);
  Result := Create(Input^, Size, Copy, Encoding);
end;

class function YamlInput.Create(const Input: UTF8String;
  Encoding: TYamlEncoding = yamlUtf8Encoding): IYamlInput;
begin
  Result := TYamlInputUTF8String.Create(Input, Encoding);
end;

class function YamlInput.Create(const Input: WideString;
  Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlInput;
begin
  if Input <> '' then
    Result := Create(Input[1], Length(Input) * 2, True, Encoding)
  else
    Result := Create(nil^, 0, False, Encoding);
end;

class function YamlInput.Create(Input: PWideChar; SizeInWideChars: Integer = -1; Copy: Boolean = True;
  Encoding: TYamlEncoding = yamlUtf16leEncoding): IYamlInput;
begin
  if SizeInWideChars < 0 then
    SizeInWideChars := WStrLen(Input);
  Result := Create(Input^, SizeInWideChars * 2, Copy, Encoding);
end;

class function YamlInput.Create(const Input: TByteDynArray;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput;
begin
  Result := TYamlInputByteDynArray.Create(Input, Encoding);
end;

class function YamlInput.Create(Input: TStream;
  Encoding: TYamlEncoding = yamlAnyEncoding): IYamlInput;
begin
  Result := TYamlInputStream.Create(Input, Encoding);
end;

type
  TYamlParserImpl = class(TInterfacedObject)
  protected
    FInput: IYamlInput;
    FDone: Boolean;
    FParser: PYamlParser;
    FParserError: PYamlParserError;
    FParserMemory: TByteDynArray;
    procedure RaiseYamlException;
  public
    constructor Create(const Input: IYamlInput);
    destructor Destroy; override;
  end;

  TYamlTokenParserImpl = class(TYamlParserImpl, IYamlTokenParser)
  public
    function Next(var Token: IYamlToken): Boolean;
  end;
  TYamlEventParserImpl = class(TYamlParserImpl, IYamlEventParser)
  public
    function Next(var Event: IYamlEvent): Boolean;
  end;
  TYamlDocumentParserImpl = class(TYamlParserImpl, IYamlDocumentParser)
  public
    function Next(var Document: IYamlDocument): Boolean;
  end;

procedure TYamlParserImpl.RaiseYamlException;
begin
  case FParserError.error of
  yamlMemoryError:
    raise EYamlMemoryError.Create('YamlParser: out of memory');
  yamlReaderError:
    raise EYamlReaderError.Create(UTF8ToUnicodeString(FParserError.problem),
      FParserError.problem_value, FParserError.problem_offset);
  yamlScannerError:
    raise EYamlScannerError.Create(UTF8ToUnicodeString(FParserError.context),
      TYamlMarkImpl.Create(@(FParserError.context_mark)),
      UTF8ToUnicodeString(FParserError.problem),
      TYamlMarkImpl.Create(@(FParserError.problem_mark)));
  yamlParserError:
    raise EYamlParserError.Create(UTF8ToUnicodeString(FParserError.problem),
      TYamlMarkImpl.Create(@(FParserError.problem_mark)));
  yamlComposerError:
    raise EYamlComposerError.Create(UTF8ToUnicodeString(FParserError.context),
      TYamlMarkImpl.Create(@(FParserError.context_mark)),
      UTF8ToUnicodeString(FParserError.problem),
      TYamlMarkImpl.Create(@(FParserError.problem_mark)));
  else
    raise EYamlError.Create('YamlParser: Internal error');
  end;
end;

function YamlInputAdapter(var data; buffer: PAnsiChar;
  size: Integer; var size_read: Integer): Integer; cdecl;
begin
  try
    if IYamlInput(data).IsEof then
    begin
      size_read := 0;
      Result := 1;
    end else
    begin
      size_read := IYamlInput(data).Read(buffer^, size);
      Result := 1;
    end;
  except
    Result := 0;
  end;
end;

constructor TYamlParserImpl.Create(const Input: IYamlInput);
var
  InputAsIYamlInputMemory: IYamlInputMemory;
  InputAsIYamlInputStream: IYamlInputStream;
begin
  if not Assigned(Input) then
    raise ERangeError.Create('YamlParser.Create: Input = nil');
  inherited Create;
  FInput := Input;
  SetLength(FParserMemory, SizeOfTYamlParser);
  FParser := PYamlParser(Pointer(@(FParserMemory[0])));
  FParserError := PYamlParserError(Pointer(@(FParserMemory[0])));
  if _yaml_parser_initialize(FParser) = 0 then
    raise EYamlMemoryError.Create('YamlParser.Create: out of memory');
  _yaml_parser_set_encoding(FParser, FInput.Encoding);
  if Supports(FInput, IYamlInputMemory, InputAsIYamlInputMemory) then
  begin
    _yaml_parser_set_input_string(FParser,
      PAnsiChar(InputAsIYamlInputMemory.Mem), InputAsIYamlInputMemory.Size);
  end else if Supports(FInput, IYamlInputStream, InputAsIYamlInputStream) then
  begin
    _yaml_parser_set_input_file(FParser, InputAsIYamlInputStream.Stream);
  end else
  begin
    _yaml_parser_set_input(FParser, YamlInputAdapter, FInput);
  end;
end;

destructor TYamlParserImpl.Destroy;
begin
  _yaml_parser_delete(FParser);
  inherited Destroy;
end;

function TYamlTokenParserImpl.Next(var Token: IYamlToken): Boolean;
var
  Temp: PYamlToken;
  TempToken: IYamlToken;
begin
  Result := not FDone;
  if FDone then
    Exit;
  TempToken := TYamlTokenImpl.Create(Temp);
  if _yaml_parser_scan(FParser, Temp) = 0 then
    RaiseYamlException;
  FDone := Temp.data.type_ = yamlStreamEndToken;
  Token := TempToken;
end;

class function YamlTokenParser.Create(const Input: IYamlInput): IYamlTokenParser;
begin
  Result := TYamlTokenParserImpl.Create(Input);
end;

function TYamlEventParserImpl.Next(var Event: IYamlEvent): Boolean;
var
  Temp: PYamlEvent;
  TempEvent: IYamlEvent;
begin
  Result := not FDone;
  if FDone then
    Exit;
  TempEvent := TYamlEventImpl.Create(Temp);
  if _yaml_parser_parse(FParser, Temp) = 0 then
    RaiseYamlException;
  FDone := Temp.data.type_ = yamlStreamEndEvent;
  Event := TempEvent;
end;

class function YamlEventParser.Create(const Input: IYamlInput): IYamlEventParser;
begin
  Result := TYamlEventParserImpl.Create(Input);
end;

function TYamlDocumentParserImpl.Next(var Document: IYamlDocument): Boolean;
var
  Temp: PYamlDocument;
  TempDocument: IYamlDocument;
begin
  Result := not FDone;
  if FDone then
    Exit;
  TempDocument := TYamlDocumentImpl.Create(Temp);
  if _yaml_parser_load(FParser, Temp) = 0 then
    RaiseYamlException;
  FDone := not Assigned(_yaml_document_get_root_node(Temp));
  Result := not FDone;
  if FDone then
    Exit;
  Document := TempDocument;
end;

class function YamlDocumentParser.Create(const Input: IYamlInput): IYamlDocumentParser;
begin
  Result := TYamlDocumentParserImpl.Create(Input);
end;

type
  TYamlOutputImpl = class(TInterfacedObject, IYamlOutput)
  protected
    FEncoding: TYamlEncoding;
    constructor Create(Encoding: TYamlEncoding);
  public
    procedure Write(const Buffer; Size: Integer); virtual; abstract;
    function GetEncoding: TYamlEncoding;
    property Encoding: TYamlEncoding read GetEncoding;
  end;

  IYamlOutputMemory = interface(IYamlOutputBuffer)
  ['{577B5A8D-AFA4-4002-B076-AEB0AB71E655}']
    function GetPSizeWritten: PInteger;
    function GetMem: Pointer;
    property PSizeWritten: PInteger read GetPSizeWritten;
    property Mem: Pointer read GetMem;
  end;

  TYamlOutputMemory = class(TYamlOutputImpl, IYamlOutputBuffer, IYamlOutputMemory)
  protected
    FMem: Pointer;
    FSize: Integer;
    FOffset: Integer;
  public
    constructor Create(Output: Pointer; Size: Integer;
      Encoding: TYamlEncoding);
    procedure Write(const Buffer; Size: Integer); override;
    function GetSize: Integer;
    function GetSizeWritten: Integer;
    function GetValue: YamlString; virtual;
    function GetPSizeWritten: PInteger;
    function GetMem: Pointer;
    property Size: Integer read GetSize;
    property SizeWritten: Integer read GetSizeWritten;
    property Value: YamlString read GetValue;
    property PSizeWritten: PInteger read GetPSizeWritten;
    property Mem: Pointer read GetMem;
  end;

  IYamlOutputStream = interface
  ['{9747F743-2CC7-4B1E-96D0-1C726B1F38FD}']
    function GetStream: TStream;
    property Stream: TStream read GetStream;
  end;

  TYamlOutputBuffer = class(TYamlOutputMemory)
  protected
    FBuffer: YamlString;
  public
    constructor Create(SizeInWideChars: Integer);
    function GetValue: YamlString; override;
  end;

  TYamlOutputStream = class(TYamlOutputImpl, IYamlOutputStream)
  protected
    FStream: TStream;
  public
    constructor Create(Output: TStream; Encoding: TYamlEncoding);
    procedure Write(const Buffer; Size: Integer); override;
    function GetStream: TStream;
    property Stream: TStream read GetStream;
  end;

constructor TYamlOutputImpl.Create(Encoding: TYamlEncoding);
begin
  inherited Create;
  FEncoding := Encoding;
end;

function TYamlOutputImpl.GetEncoding: TYamlEncoding;
begin
  Result := FEncoding;
end;

constructor TYamlOutputMemory.Create(Output: Pointer; Size: Integer;
  Encoding: TYamlEncoding);
begin
  if not Assigned(Output) then
    raise ERangeError.Create('YamlOutput.Create: Output = nil');
  inherited Create(Encoding);
  FMem := Output;
  FSize := Size;
  FOffset := 0;
end;

procedure TYamlOutputMemory.Write(const Buffer; Size: Integer);
var
  DoRaise: Boolean;
begin
  DoRaise := FOffset + Size > FSize;
  if DoRaise then
    Size := FSize - FOffset;

  Move(Buffer, (PAnsiChar(FMem) + FOffset)^, Size);
  Inc(FOffset, Size);
  // yaml_string_write_handler does write even when overflow
  // is known to happen

  if DoRaise then
    raise EYamlWriterError.Create('Write error, buffer overflow');
      // the exception message is discarded
end;

function TYamlOutputMemory.GetSize: Integer;
begin
  Result := FSize;
end;

function TYamlOutputMemory.GetSizeWritten: Integer;
begin
  Result := FOffset;
end;

function TYamlOutputMemory.GetValue: YamlString;
var
  IntValue: UTF8String;
begin
  if FEncoding = yamlUtf8Encoding then
  begin
    SetString(IntValue, PAnsiChar(FMem), FOffset);
    Result := UTF8ToUnicodeString(IntValue);
  end else
    raise EYamlError.Create('YamlOutput.Value: only UTF-8 is supported');
end;

function TYamlOutputMemory.GetPSizeWritten: PInteger;
begin
  Result := @FOffset;
end;

function TYamlOutputMemory.GetMem: Pointer;
begin
  Result := FMem;
end;

class function YamlOutput.Create(Output: Pointer; Size: Integer; Encoding: TYamlEncoding): IYamlOutput;
begin
  Result := TYamlOutputMemory.Create(Output, Size, Encoding);
end;

constructor TYamlOutputBuffer.Create(SizeInWideChars: Integer);
begin
  SetLength(FBuffer, SizeInWideChars);
  inherited Create(Pointer(FBuffer), SizeInWideChars * 2, yamlUtf16leEncoding);
end;

function TYamlOutputBuffer.GetValue: YamlString;
begin
  Result := Copy(FBuffer, 1, FOffset div 2);
end;

class function YamlOutput.Create(SizeInWideChars: Integer): IYamlOutputBuffer;
begin
  Result := TYamlOutputBuffer.Create(SizeInWideChars);
end;

constructor TYamlOutputStream.Create(Output: TStream; Encoding: TYamlEncoding);
begin
  if not Assigned(Output) then
    raise ERangeError.Create('YamlOutput.Create: Output = nil');
  inherited Create(Encoding);
  FStream := Output;
end;

procedure TYamlOutputStream.Write(const Buffer; Size: Integer);
begin
  FStream.WriteBuffer(Buffer, Size);
end;

function TYamlOutputStream.GetStream: TStream;
begin
  Result := FStream;
end;

class function YamlOutput.Create(Output: TStream; Encoding: TYamlEncoding): IYamlOutput;
begin
  Result := TYamlOutputStream.Create(Output, Encoding);
end;

type
  TYamlEmitterSettingsImpl = class(TInterfacedObject, IYamlEmitterSettings)
  protected
    FCanonical: Boolean;
    FIndent: Integer;
    FWidth: Integer;
    FUnicode: Boolean;
    FLineBreak: TYamlBreak;
  public
    constructor Create(Canonical: Boolean = False; Indent: Integer = 2;
      Width: Integer = 80; Unicode: Boolean = True; LineBreak: TYamlBreak = yamlCrLnBreak);
    function SetCanonical(Canonical: Boolean): IYamlEmitterSettings;
    function SetIndent(Indent: Integer): IYamlEmitterSettings;
    function SetWidth(Width: Integer): IYamlEmitterSettings;
    function SetUnicode(Unicode: Boolean): IYamlEmitterSettings;
    function SetLineBreak(LineBreak: TYamlBreak): IYamlEmitterSettings;
    function GetCanonical: Boolean;
    function GetIndent: Integer;
    function GetWidth: Integer;
    function GetUnicode: Boolean;
    function GetLineBreak: TYamlBreak;
    property Canonical: Boolean read GetCanonical;
    property Indent: Integer read GetIndent;
    property Width: Integer read GetWidth;
    property Unicode: Boolean read GetUnicode;
    property LineBreak: TYamlBreak read GetLineBreak;
  end;

constructor TYamlEmitterSettingsImpl.Create(Canonical: Boolean = False; Indent: Integer = 2;
  Width: Integer = 80; Unicode: Boolean = True; LineBreak: TYamlBreak = yamlCrLnBreak);
begin
  inherited Create;
  FCanonical := Canonical; FIndent := Indent; FWidth := Width;
  FUnicode := Unicode; FLineBreak := LineBreak;
end;

function TYamlEmitterSettingsImpl.SetCanonical(Canonical: Boolean): IYamlEmitterSettings;
begin
  Result := TYamlEmitterSettingsImpl.Create(Canonical, FIndent, FWidth, FUnicode, FLineBreak);
end;

function TYamlEmitterSettingsImpl.SetIndent(Indent: Integer): IYamlEmitterSettings;
begin
  if not ((1 < Indent) and (Indent < 10)) then
    Indent := 2; 
  Result := TYamlEmitterSettingsImpl.Create(FCanonical, Indent, FWidth, FUnicode, FLineBreak);
end;

function TYamlEmitterSettingsImpl.SetWidth(Width: Integer): IYamlEmitterSettings;
begin
  if Width < 0 then
    Width := -1
  else if Width <= FIndent * 2 then
    Width := 80;
  Result := TYamlEmitterSettingsImpl.Create(FCanonical, FIndent, Width, FUnicode, FLineBreak);
end;

function TYamlEmitterSettingsImpl.SetUnicode(Unicode: Boolean): IYamlEmitterSettings;
begin
  Result := TYamlEmitterSettingsImpl.Create(FCanonical, FIndent, FWidth, Unicode, FLineBreak);
end;

function TYamlEmitterSettingsImpl.SetLineBreak(LineBreak: TYamlBreak): IYamlEmitterSettings;
begin
  Result := TYamlEmitterSettingsImpl.Create(FCanonical, FIndent, FWidth, FUnicode, LineBreak);
end;

function TYamlEmitterSettingsImpl.GetCanonical: Boolean;
begin
  Result := FCanonical;
end;

function TYamlEmitterSettingsImpl.GetIndent: Integer;
begin
  Result := FIndent;
end;

function TYamlEmitterSettingsImpl.GetWidth: Integer;
begin
  Result := FWidth;
end;

function TYamlEmitterSettingsImpl.GetUnicode: Boolean;
begin
  Result := FUnicode;
end;

function TYamlEmitterSettingsImpl.GetLineBreak: TYamlBreak;
begin
  Result := FLineBreak;
end;

type
  TYamlEmitterImpl = class(TInterfacedObject)
  protected
    FOutput: IYamlOutput;
    FEmitter: PYamlEmitter;
    FEmitterError: PYamlEmitterError;
    FEmitterMemory: TByteDynArray;
    FFlushed: Boolean; 
    procedure RaiseYamlException;
  public
    constructor Create(const Output: IYamlOutput; const Settings: IYamlEmitterSettings);
    destructor Destroy; override;
    procedure Flush;
  end;

  TYamlEventEmitter = class(TYamlEmitterImpl, IYamlEventEmitter)
  public
    procedure Emit(var Event: IYamlEvent);
  end;

  TYamlDocumentEmitter = class(TYamlEmitterImpl, IYamlDocumentEmitter)
  protected
    FOpened, FClosed: Boolean;
  public
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure Dump(var Document: IYamlDocument);
  end;


procedure TYamlEmitterImpl.RaiseYamlException;
begin
  case FEmitterError.error of
  yamlMemoryError:
    raise EYamlMemoryError.Create('YamlEmitter: out of memory');
  yamlWriterError:
    raise EYamlWriterError.Create(UTF8ToUnicodeString(FEmitterError.problem));
  yamlEmitterError:
    raise EYamlEmitterError.Create(UTF8ToUnicodeString(FEmitterError.problem));
  else
    raise EYamlError.Create('YamlEmitter: Internal error');
  end;
end;

function YamlOutputAdapter(var data; buffer: PAnsiChar; size: Integer):
  Integer; cdecl;
begin
  try
    IYamlOutput(data).Write(buffer^, size);
    Result := 1;
  except
    Result := 0;
  end;
end;

constructor TYamlEmitterImpl.Create(const Output: IYamlOutput; const Settings: IYamlEmitterSettings);
var
  OutputAsIYamlOutputMemory: IYamlOutputMemory;
  OutputAsIYamlOutputStream: IYamlOutputStream;
begin
  if not Assigned(Output) then
    raise ERangeError.Create('YamlEmitter.Create: Output = nil');
  inherited Create;
  FFlushed := True;
  FOutput := Output;
  SetLength(FEmitterMemory, SizeOfTYamlEmitter);
  FEmitter := PYamlEmitter(Pointer(@(FEmitterMemory[0])));
  FEmitterError := PYamlEmitterError(Pointer(@(FEmitterMemory[0])));
  if _yaml_emitter_initialize(FEmitter) = 0 then
    raise EYamlMemoryError.Create('YamlEmitter.Create: out of memory');
  _yaml_emitter_set_encoding(FEmitter, FOutput.Encoding);
  if Supports(FOutput, IYamlOutputMemory, OutputAsIYamlOutputMemory) then
  begin
    _yaml_emitter_set_output_string(FEmitter, OutputAsIYamlOutputMemory.Mem,
      OutputAsIYamlOutputMemory.Size, OutputAsIYamlOutputMemory.PSizeWritten^);
  end else if Supports(FOutput, IYamlInputStream, OutputAsIYamlOutputStream) then
  begin
    _yaml_emitter_set_output_file(FEmitter, OutputAsIYamlOutputStream.Stream);
  end else
  begin
    _yaml_emitter_set_output(FEmitter, YamlOutputAdapter, FOutput);
  end;

  if not Assigned(Settings) then
  begin
    _yaml_emitter_set_canonical(FEmitter, 0);
    _yaml_emitter_set_indent(FEmitter, 2);
    _yaml_emitter_set_width(FEmitter, 80);
    _yaml_emitter_set_unicode(FEmitter, 1);
    _yaml_emitter_set_break(FEmitter, yamlCrLnBreak);
  end else begin
    _yaml_emitter_set_canonical(FEmitter, Integer(Settings.Canonical));
    _yaml_emitter_set_indent(FEmitter, Settings.Indent);
    _yaml_emitter_set_width(FEmitter, Settings.Width);
    _yaml_emitter_set_unicode(FEmitter, Integer(Settings.Unicode));
    _yaml_emitter_set_break(FEmitter, Settings.LineBreak);
  end;
end;

destructor TYamlEmitterImpl.Destroy;
begin
  if not FFlushed then
  try
    Flush;
  except
    // this is a destructor, we can't do anything meaningful
  end;
  _yaml_emitter_delete(FEmitter);
  inherited Destroy;
end;

procedure TYamlEmitterImpl.Flush;
begin
  if _yaml_emitter_flush(FEmitter) = 0 then
    RaiseYamlException;
  FFlushed := True;
end;

procedure TYamlEventEmitter.Emit(var Event: IYamlEvent);
var
  EventPtr: PYamlEvent;
  EventAsIYamlEventImpl: IYamlEventImpl;
begin
  if not Assigned(Event) then
    raise ERangeError.Create('YamlEventEmitter.Emit: Event = nil');
  FFlushed := False;
  try
    if not Supports(Event, IYamlEventImpl, EventAsIYamlEventImpl) then
      raise ERangeError.Create('YamlEventEmitter.Emit: Event is not created by YamlIntermediate');
    EventPtr := EventAsIYamlEventImpl.YamlEvent;
    try
      if _yaml_emitter_emit(FEmitter, EventPtr) = 0 then
        RaiseYamlException;
    finally
      FillChar(EventPtr^, SizeOf(TYamlEvent), 0);
      // emit effectively acquires event but does not
      // clean the original object
    end;
  finally
    Event := nil;
    // The event object is destroyed even if the function fails.
    // This is an excerpt from yaml.h
    // libyaml single-reference API is not mapped
    // flawlessly to reference-counted Delphi-YAML intermediate
    // binding.
    // A proper (correct) way to implement intermediate
    // binding is to implement a clone and always emit
    // an internally destroyed clone.
    // This has serious performance drawbacks when it takes to
    // cloning large documents.
    // Instead we emulate libyaml API by requiring in-out
    // argument that we destroy whatever happens.
  end;
end;

class function YamlEventEmitter.Create(const Output: IYamlOutput;
  const Settings: IYamlEmitterSettings = nil): IYamlEventEmitter;
begin
  Result := TYamlEventEmitter.Create(Output, Settings);
end;

class function YamlEventEmitter.Settings: IYamlEmitterSettings;
begin
  Result := TYamlEmitterSettingsImpl.Create;
end;

destructor TYamlDocumentEmitter.Destroy;
begin
  if FOpened and not FClosed then
  try
    Close;
  except
    // this is a destructor, we can't do anything meaningful
  end;
  inherited Destroy;
end;

procedure TYamlDocumentEmitter.Open;
begin
  if FOpened then
    raise ERangeError.Create('YamlDocumentEmitter.Open: emitter is already opened');
  if FClosed then
    raise ERangeError.Create('YamlDocumentEmitter.Open: emitter is already closed');
  FFlushed := False;
  if _yaml_emitter_open(FEmitter) = 0 then
    RaiseYamlException;
  FOpened := True;
end;

procedure TYamlDocumentEmitter.Close;
begin
  if not FOpened then
    raise ERangeError.Create('YamlDocumentEmitter.Close: emitter isn''t opened yet');
  if FClosed then
    raise ERangeError.Create('YamlDocumentEmitter.Close: emitter is already closed');
  FFlushed := False;
  if _yaml_emitter_close(FEmitter) = 0 then
    RaiseYamlException;
  FOpened := False;
  FClosed := True;
end;

procedure TYamlDocumentEmitter.Dump(var Document: IYamlDocument);
var
  DocumentPtr: PYamlDocument;
  DocumentAsIYamlDocumentImpl: IYamlDocumentImpl;
begin
  if not Assigned(Document) then
    raise ERangeError.Create('YamlDocumentEmitter.Dump: Document = nil');
  FFlushed := False;
  try
    if FClosed then
      raise ERangeError.Create('YamlDocumentEmitter.Dump: emitter is already closed');
    if not FOpened then
      Open;
    if not Supports(Document, IYamlDocumentImpl, DocumentAsIYamlDocumentImpl) then
      raise ERangeError.Create('YamlDocumentEmitter.Dump: Document is not created by YamlIntermediate');
    DocumentPtr := DocumentAsIYamlDocumentImpl.YamlDocument;
    try
      if _yaml_emitter_dump(FEmitter, DocumentPtr) = 0 then
        RaiseYamlException;
    finally
      FillChar(DocumentPtr^, SizeOf(TYamlDocument), 0);
    end;
  finally
    Document := nil; // see above TYamlEventEmitter.Emit
  end;
end;

class function YamlDocumentEmitter.Create(const Output: IYamlOutput;
  const Settings: IYamlEmitterSettings = nil): IYamlDocumentEmitter;
begin
  Result := TYamlDocumentEmitter.Create(Output, Settings);
end;

class function YamlDocumentEmitter.Settings: IYamlEmitterSettings;
begin
  Result := TYamlEmitterSettingsImpl.Create;
end;

end.
