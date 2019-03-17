module engine.script.attrib;


/// Specifies the type of method that the binding will deal with
enum MethodType : string
{
  none = "none_method",
  func = "function",
  method = "method",
  ctor = "ctor"
}
/// Specifies the kind of return value the binding will deal in
enum RetType : string
{
  none = "none_rettype",
  lightud = "lightud_rettype",
  userdat = "userdat_rettype",
  str = "string",
  number = "number"
}
/// Specifies the type of data that the binding should treat as
enum MemberType : string
{
  none = "none_memtype",
  lightud = "lightud_memtype",
  userdat = "userdat_memtype",
}
/// Declare above desired field to have the luabinding pick it up
/// For classes, only the name field matters
struct ScriptExport
{
  /// Name that luad should use (unimplemented yet)
  string name = "";
  /// Help the exporting routine distinguish things like userdata vs lightuserdata
  MethodType type;
  /// Sub-member to refer to during the exporting routine
  string submember = "";
  /// Return type to put on the stack
  RetType rtype;
  /// Member type
  MemberType memtype;
}