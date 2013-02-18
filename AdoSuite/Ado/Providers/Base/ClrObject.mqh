//+------------------------------------------------------------------+
//|                                                    ClrObject.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "..\..\AdoErrors.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
   long CreateManagedObject(const string, const string, string&, string&);
   void DestroyManagedObject(const long, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian ������ ����������� ����� .NET.
///         \~english Represents CLR Object.
///
/// \~russian �������� ����������� ������ ��� �������� � ����������� ����������� ��������, ��������� ���������� ��� ������. �������� ������� ������
/// \~english Includes neccessary methods for creating and disposing managed objects, exception handling. Abstract class
class CClrObject
{
private:
// variables
   bool _IsCreated, _IsAssigned;
   long _ClrHandle;
   string _MqlTypeName;

protected:
   
// properties
   
   /// \brief  \~russian ���������� ��� ����, ������� ������������ ����������� �����
   ///         \~english Gets type string of inherited class
   const string MqlTypeName() { return _MqlTypeName; }
   /// \brief  \~russian ������������� ��� ����, ������� ������������ ����������� �����
   ///         \~english Sets type string of inherited class
   void MqlTypeName(const string value) { _MqlTypeName = value; }
   
// methods
   
   /// \brief  \~russian ������� ������ CLR 
   ///         \~english Creates CLR object
   /// \~russian \param  asmName   ��� ������. ������������ �������� ��� ������: System, System.Data � � � 
   /// \~english \param  asmName   short assembly name: System, System.Data etc
   /// \~russian \param  typeName  ������ ��� ����: System.String, System.Data.DataTable � � �
   /// \~english \param  typeName  full type name eg System.String, System.Data.DataTable etc
   void CreateClrObject(const string asmName, const string typeName);   
   /// \brief  \~russian ���������� ������ CLR. ������������� ���������� � �����������, ������� ���� �������� �� �����!
   ///         \~english Destroys CLR object. Called automatically in desctructor, so dont call it explictly!
   void DestroyClrObject();
   
// events

   /// \brief  \~russian ���������� ����� ��� ��� ������ ����� ������. ����������� �����
   ///         \~english Called before object is being created. Virtual
   /// \~russian \param isCanceling  ���������� bool, ������������ �� c�����. ���� ���������� �������� false, �� �������� ������� ����� ���������
   /// \~english \param isCanceling  bool variable, passed by a reference. If set value to false, then object creation will be suppressed
   /// \~russian \param creating    true - ���� ������ ���������, false - ���� ������ ������������� ����� ������� CClrObject::Assign
   /// \~english \param creating    when true indicates that object is creating, otherwise object is assigning using CClrObject::Assign
   virtual void OnObjectCreating(bool& isCanceling, bool creating = true)   {}
   /// \brief  \~russian ���������� ����� ����, ��� Clr ������ ������. ����������� �����
   ///         \~english Called after CLR object was created
   virtual void OnObjectCreated()                        {}
   /// \brief  \~russian ���������� ����� ���, ��� Clr ������ ����� ���������. ����������� �����
   ///         \~english Called before object is being destroyed. Virtual
   virtual void OnObjectDestroying()                     {}
   /// \brief  \~russian ���������� ����� ����, ��� Clr ������ ���������. ����������� �����
   ///         \~english Called after CLR object was destroyed
   virtual void OnObjectDestroyed()                      {}
   
   /// \brief  \~russian ���������� � ������ ����������(������). ����������� �����.
   ///         \~english Called when an exception occurs. Virtual
   /// \~russian \param method    ��� ������, � ������� ��������� ����������
   /// \~english \param method    method name where the exception was thrown
   /// \~russian \param type      ��� ����������. ������ ���� �� .NET ����� 
   /// \~english \param type      exception type. Usually one of .NET types
   /// \~russian \param message   ��������� ���������� �� ������ 
   /// \~english \param message   exception message. Describes error details
   /// \~russian \param mqlErr    ������ mql, ��������������� ������� ����������. �� ��������� ADOERR_FIRST  
   /// \~english \param mqlErr    appropriate mql error equivalent. ADOERR_FIRST by default
  virtual void OnClrException(const string method, const string type, const string message, const ushort mqlErr);
   
public: 
   /// \brief  \~russian ����������� ������
   ///         \~english constructor
   CClrObject() { _MqlTypeName = "CClrObject"; }
   /// \brief  \~russian ���������� ������
   ///         \~english destructor
   ~CClrObject() { DestroyClrObject(); }
   
// properties
   
   /// \brief  \~russian ���������� ��������� �� GCHandle, ���������� ������
   ///         \~english Returns pointer for GCHandle, catching the object
   const long ClrHandle() { return _ClrHandle; }
   /// \brief  \~russian ���������� true ���� ������ ��� ��������, � ��������� ������ false
   ///         \~english Indicates whether object was assigned
   const bool IsAssigned() { return _IsAssigned; }
   /// \brief  \~russian ���������� true ���� ������ ��� ������ �� mql ����, � ��������� ������ false
   ///         \~english Indicates whether object was created
   const bool IsCreated() { return _IsCreated; }
   
// methods

   /// \brief  \~russian ������������ ������ � ��� ���������� ������� CLR 
   ///         \~english Assigns this object to an existing CLR object
   /// \~russian \param handle       ��������� �� GCHanlde, ���������� ������ 
   /// \~english \param handle       pointer to GCHanlde with object
   /// \~russian \param autoDestroy  true - ���� CLR ������ ���������� ���������� � ������������ ���������������� ��lrObject, false - ���� ������ ����� �������� � ������. �� ��������� false.
   /// \~english \param autoDestroy  Indicates whether CLR object has to be destroyed with appropriate ��lrObject
   void Assign(const long handle, const bool autoDestroy); 
};

//--------------------------------------------------------------------
void CClrObject::CreateClrObject(const string asmName, const string typeName)
{
   bool isCanceling = false;
   
   OnObjectCreating(isCanceling, true);
   
   if (isCanceling) return;
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);

   _ClrHandle = CreateManagedObject(asmName, typeName, exType, exMsg);
   
   if (exType != "") 
   {
      _IsCreated = false;
      OnClrException("CreateClrObject", exType, exMsg);
   }
   else _IsCreated = true;
   _IsAssigned = false;
   
   OnObjectCreated();

}

//--------------------------------------------------------------------
CClrObject::DestroyClrObject(void)
{
   if (!_IsCreated) return;

   OnObjectDestroying();
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
 
   DestroyManagedObject(_ClrHandle, exType, exMsg);
   
   _IsCreated = false;
   
   if (exType != "") 
      OnClrException("DestroyClrObject", exType, exMsg);
   
   OnObjectDestroyed();
}

//--------------------------------------------------------------------
CClrObject::Assign(const long handle, const bool autoDestroy = false)
{
   bool isCanceling = false;
   OnObjectCreating(isCanceling, false);
   
   if (isCanceling) return;
    
   _ClrHandle = handle;
   _IsCreated = autoDestroy;
   _IsAssigned = true;
  
   OnObjectCreated();
}

//--------------------------------------------------------------------
CClrObject::OnClrException(const string method, const string type, const string message, const ushort mqlErr = ADOERR_FIRST)
{
   Alert("����� ", _MqlTypeName, "::", method, " ����� ���������� ���� ", type, ":\r\n", message);
   SetUserError(mqlErr);
}
