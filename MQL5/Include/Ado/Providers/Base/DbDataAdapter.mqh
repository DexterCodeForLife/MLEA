//+------------------------------------------------------------------+
//|                                                DbDataAdapter.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

#include "ClrObject.mqh"
#include "DbCommand.mqh"
#include "DbConnection.mqh"
#include "..\..\AdoTypes.mqh"
#include "..\..\Data.mqh"
#include "..\..\AdoErrors.mqh"
//--------------------------------------------------------------------
/// \brief  \~russian ����� ������ ��� ��������� AdoTable ������� �� ���� ������
///         \~english Used for filling AdoTable
class CDbDataAdapter : public CClrObject
  {
private:
   CDbCommand       *_SelectCommand;

public:
   /// \brief  \~russian ����������� ������
   ///         \~english constructor
                     CDbDataAdapter() { MqlTypeName("CDbDataAdapter"); }
   /// \brief  \~russian ���������� ������
   ///         \~english destructor
                    ~CDbDataAdapter();

   // properties

   /// \brief  \~russian ���������� ��������, ����� ������� ����� �������� AdoTable
   ///         \~english Gets command with select statement
   CDbCommand *SelectCommand() { return _SelectCommand; }
   /// \brief  \~russian ������ ��������, ����� ������� ����� �������� AdoTable
   ///         \~english Sets command with select statement
   void              SelectCommand(CDbCommand *value);

   // methods

   /// \brief  \~russian ��������� AdoTable � ������������ � ��������, �������� ����� CDbDataAdapter::SelectCommand
   ///         \~english Fills AdoTable in accordance with command, set through CDbDataAdapter::SelectCommand
   void              Fill(CAdoTable *table);
  };
//--------------------------------------------------------------------
CDbDataAdapter::~CDbDataAdapter(void)
  {
   if(CheckPointer(_SelectCommand)==POINTER_DYNAMIC)
     {
      delete _SelectCommand;
      _SelectCommand=NULL;
     }
  }
//--------------------------------------------------------------------
CDbDataAdapter::SelectCommand(CDbCommand *value)
  {
   if(value==NULL)
     {
      OnClrException("Fill","ArgumentException","");
      return;
     }

   _SelectCommand=value;
  }
//--------------------------------------------------------------------
CDbDataAdapter::Fill(CAdoTable *table)
  {
   if(table==NULL)
     {
      OnClrException("Fill","ArgumentException","");
      return;
     }

   if(_SelectCommand==NULL)
     {
      OnClrException("Fill","ArgumentException","SelectCommand is NULL");
      return;
     }

   table.Columns().Clear();
   table.Records().Clear();
   ResetAdoError();

   CDbConnection *conn=_SelectCommand.Connection();

   ENUM_CONNECTION_STATE state=conn.State();

   if(state==CONSTATE_CLOSED)
     {
      conn.Open();
      if(CheckAdoError())
         return;
     }

   CDbDataReader *reader=_SelectCommand.ExecuteReader();

   for(int i=0; i<reader.FieldCount(); i++)
      table.Columns().AddColumn(reader.FieldName(i),reader.FieldType(i));

   while(reader.Read())
     {
      CAdoRecord *newRec=table.CreateRecord();
      for(int i=0; i<reader.FieldCount(); i++)
         switch(reader.GetValue(i).Type())
           {
            case ADOTYPE_BOOL:
               newRec.Values().GetValue(i).SetValue(reader.GetValue(i).ToBool());
               break;

            case ADOTYPE_LONG:
               newRec.Values().GetValue(i).SetValue(reader.GetValue(i).ToLong());
               break;

            case ADOTYPE_DOUBLE:
               newRec.Values().GetValue(i).SetValue(reader.GetValue(i).ToDouble());
               break;

            case ADOTYPE_STRING:
               newRec.Values().GetValue(i).SetValue(reader.GetValue(i).ToString());
               break;

            case ADOTYPE_DATETIME:
              {
               MqlDateTime mdt;
               mdt=reader.GetValue(i).ToDatetime();
               newRec.Values().GetValue(i).SetValue(mdt);
              }
            break;

            default: break;
           }
      table.Records().Add(newRec);
     }

   delete reader;

   if(state==CONSTATE_CLOSED)
      conn.Close();

  }
//+------------------------------------------------------------------+
