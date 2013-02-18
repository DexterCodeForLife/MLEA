//+------------------------------------------------------------------+
//|                                                    DbCommand.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

//--------------------------------------------------------------------
#include "ClrObject.mqh"
#include "DbConnection.mqh"
#include "DbTransaction.mqh"
#include "DbDataReader.mqh"
#include "DbParameterList.mqh"
#include "..\..\AdoTypes.mqh"
#include "..\..\Data\AdoValue.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
   long GetDbCommandParameterList(const long, string&, string&);
   void SetDbCommandText(const long, const string, string&, string&);
	string GetDbCommandText(const long, string&, string&);
	void SetDbCommandTimeout(const long, const int, string&, string&);
	int GetDbCommandTimeout(const long, string&, string&);
	void SetDbCommandType(const long, const int, string&, string&);
	int GetDbCommandType(const long, string&, string&);
	void SetDbCommandConnection(const long, const long, string&, string&);
	void 	SetDbCommandTransaction(const long, const long, string&, string&);
	void DbCommandExecuteNonQuery(const long, string&, string&);
	long DbCommandExecuteReader(const long, string&, string&);
	int DbCommandExecuteScalar(const long, long&, string&, string&);
	bool DbCommandScalarGetBool(const long, string&, string&);
	long DbCommandScalarGetLong(const long, string&, string&);
	double DbCommandScalarGetDouble(const long, string&, string&);
	string DbCommandScalarGetString(const long, string&, string&);
	void DbCommandScalarGetDatetime(const long, MqlDateTime&, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian ������������, �������������� ��� �������
///         \~english Command types
enum ENUM_COMMAND_TYPES
{
    CMDTYPE_STOREDPROCEDURE = 4,
    CMDTYPE_TABLEDIRECT = 0x200,
    CMDTYPE_TEXT = 1
};

//--------------------------------------------------------------------
/// \brief  \~russian �����, �������������� ����������� ������� � ������� ��������� ������
///         \~english Represents an SQL statement or stored procedure to execute against a data source
class CDbCommand : public CClrObject
{
private:
// variables
   CDbParameterList* _Parameters;
   CDbConnection* _Connection;
   CDbTransaction* _Transaction;

protected:
// methods
   
   /// \brief  \~russian ������� ������ ���������� �������. ����������� �����. ������ ���� ������������� � �����������
   ///         \~english Creates parameter collection for the command. Virtual. Must be overriden
   virtual CDbParameterList* CreateParameters() { return NULL; }

   /// \brief  \~russian ������� ������, ����������� CDbDataReader ��� ��������� ������. ����������� �����. ������ ���� ������������� � �����������
   ///         \~english Creates CDbDataReader for the command. Virtual. Must be overriden
   virtual CDbDataReader* CreateReader() { return NULL; }
   
   // events
   virtual void OnObjectCreated();
   
public:
   /// \brief  \~russian ����������� ������
   ///         \~english constructor
   CDbCommand() { MqlTypeName("CDbCommand"); }
   /// \brief  \~russian ���������� ������
   ///         \~english destructor
   ~CDbCommand();

// properties
   /// \brief  \~russian ���������� ����� �������
   ///         \~english Gets command text
   const string CommandText();
   /// \brief  \~russian ������ ����� �������
   ///         \~english Sets command text
   void CommandText(const string value);
   
   /// \brief  \~russian ���������� ������������ �����, � ������� �������� ������� ������ �����������
   ///         \~english Gets command timeout
   const int CommandTimeout();
   /// \brief  \~russian ������ ������������ �����, � ������� �������� ������� ������ �����������
   ///         \~english Sets command timeout
   void CommandTimeout(const int value);
   
   /// \brief  \~russian ���������� ��� �������
   ///         \~english Gets command type
   const ENUM_COMMAND_TYPES CommandType();
   /// \brief  \~russian ������ ��� �������
   ///         \~english Sets command type
   void CommandType(const ENUM_COMMAND_TYPES value);
   
   /// \brief  \~russian ���������� ������ ����������, ����� ������� �������� �������
   ///         \~english Gets connection used by the command
   CDbConnection* Connection()   { return _Connection; }
   /// \brief  \~russian ������ ������ ����������, ����� ������� ����� �������� �������
   ///         \~english Sets connection used by the command
   void Connection(CDbConnection* value);
   
   /// \brief  \~russian ���������� ����������, � ������� ����������� �������
   ///         \~english Gets transaction within which this command executes
   CDbTransaction* Transaction()   { return _Transaction; }
   /// \brief  \~russian ������ ����������, � ������� ������ ����������� �������
   ///         \~english Sets transaction within which this command executes
   void Transaction(CDbTransaction* value);
   
   /// \brief  \~russian ���������� ������ ���������� �������
   ///         \~english Get command parameter list
   CDbParameterList* Parameters();
   
// methods
   /// \brief  \~russian ��������� �������, ������� �� ���������� ��������
   ///         \~english Executes a command against a connection object
   void ExecuteNonQuery();
   /// \brief  \~russian ��������� ������� �� �������, � ���������� ������, ����������� �� DbDataReader
   ///         \~english Executes a command against a connection object and returns DbDataReader
   CDbDataReader* ExecuteReader();
   /// \brief  \~russian ��������� �������, ������������ ���� �������� (������ ������ ������ ������ �������, ������� ���)
   ///         \~english Executes the query and returns the first column of the first row in the result set returned by the query
   CAdoValue* ExecuteScalar();
  
};

//--------------------------------------------------------------------
CDbCommand::~CDbCommand(void)
{
   if (CheckPointer(_Parameters) == POINTER_DYNAMIC)
   {
      delete _Parameters;
      _Parameters = NULL;
   }
}

//--------------------------------------------------------------------
CDbCommand::OnObjectCreated(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   long hParameters = GetDbCommandParameterList(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("OnObjectCreated", exType, exMsg);
      return;
   }
      
   Parameters().Assign(hParameters);
}
//--------------------------------------------------------------------
CDbParameterList* CDbCommand::Parameters()
{
   if (!CheckPointer(_Parameters))
      _Parameters = CreateParameters();
      
   return _Parameters;
}


//--------------------------------------------------------------------
string CDbCommand::CommandText(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   string value = GetDbCommandText(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("CommandText(get)", exType, exMsg);

   return value;
}

//--------------------------------------------------------------------
CDbCommand::CommandText(const string value)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   SetDbCommandText(ClrHandle(), value, exType, exMsg);
   
   if (exType != "") 
      OnClrException("CommandText(set)", exType, exMsg);
}

//--------------------------------------------------------------------
int CDbCommand::CommandTimeout()
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   int value = GetDbCommandTimeout(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("CommandTimeout(get)", exType, exMsg);

   return value;
}

//--------------------------------------------------------------------
CDbCommand::CommandTimeout(const int value)
{
   if (value <= 0)
   {
      OnClrException("CommandTimeout(set)", "ArgumentException", "");
      return;
   }
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   SetDbCommandTimeout(ClrHandle(), value, exType, exMsg);
   
   if (exType != "") 
      OnClrException("CommandTimeout(set)", exType, exMsg);
}

//--------------------------------------------------------------------
ENUM_COMMAND_TYPES CDbCommand::CommandType()
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   ENUM_COMMAND_TYPES value = GetDbCommandType(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("CommandType(get)", exType, exMsg);
      return -1;
   }

   return value;
}

//--------------------------------------------------------------------
CDbCommand::CommandType(const ENUM_COMMAND_TYPES value)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   SetDbCommandType(ClrHandle(), value, exType, exMsg);
   
   if (exType != "") 
      OnClrException("CommandType(set)", exType, exMsg);
}

//--------------------------------------------------------------------
CDbCommand::Connection(CDbConnection *value)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   SetDbCommandConnection(ClrHandle(), value.ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("Connection(set)", exType, exMsg);
   else _Connection = value;
}

//--------------------------------------------------------------------
CDbCommand::Transaction(CDbTransaction *value)
{
   if (value == NULL)
   {
      OnClrException("Transaction(set)", "ArgumentException", "");
      return;
   }
   
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   SetDbCommandTransaction(ClrHandle(), value.ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("Transaction(set)", exType, exMsg);
   else _Transaction = value;
}

//--------------------------------------------------------------------
CDbCommand::ExecuteNonQuery(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   DbCommandExecuteNonQuery(ClrHandle(),  exType, exMsg);
   
   if (exType != "") 
      OnClrException("ExecuteNonQuery(set)", exType, exMsg);
}

//--------------------------------------------------------------------
CAdoValue* CDbCommand::ExecuteScalar(void)
{  
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   long hObject = 0;
   int type = DbCommandExecuteScalar(ClrHandle(), hObject, exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("ExecuteScalar[execute]", exType, exMsg);
      return NULL;
   }
   
   // db returned DBNull value or unsupported type
   if (type == -1) return NULL;

   CAdoValue* result = new CAdoValue();
    
   switch (type + ADOTYPE_VALUE)
   {
      case ADOTYPE_BOOL:
         result.SetValue(DbCommandScalarGetBool(hObject, exType, exMsg));
         break;
   
      case ADOTYPE_LONG:
         result.SetValue(DbCommandScalarGetLong(hObject, exType, exMsg));
         break;

      case ADOTYPE_DOUBLE:
         result.SetValue(DbCommandScalarGetDouble(hObject, exType, exMsg));
         break;

      case ADOTYPE_STRING:
         result.SetValue(DbCommandScalarGetString(hObject, exType, exMsg));
         break;

      case ADOTYPE_DATETIME:
         {
            MqlDateTime mdt;
            DbCommandScalarGetDatetime(hObject, mdt, exType, exMsg);
            result.SetValue(mdt);
         }
         break;
      default:
         exType = "UnknownAdoTypeException";
         break;
   }   

   if (exType != "") 
   {
      OnClrException("ExecuteScalar[get val]", exType, exMsg);
      return NULL;
   }
   
   return result;
}

//--------------------------------------------------------------------
CDbDataReader* CDbCommand::ExecuteReader(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   long hReader = DbCommandExecuteReader(ClrHandle(),  exType, exMsg);
   
   if (exType != "") 
   {
      OnClrException("ExecuteReader", exType, exMsg);
      return NULL;
   }
      
   CDbDataReader* reader = CreateReader();
   reader.Assign(hReader, true);
   
   return reader;
}