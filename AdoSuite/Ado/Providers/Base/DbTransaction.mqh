//+------------------------------------------------------------------+
//|                                                DbTransaction.mqh |
//|                                             Copyright GF1D, 2010 |
//|                                             garf1eldhome@mail.ru |
//+------------------------------------------------------------------+
#property copyright "GF1D, 2010"
#property link      "garf1eldhome@mail.ru"

//--------------------------------------------------------------------
#include "ClrObject.mqh"

//--------------------------------------------------------------------
#import "AdoSuite.dll"
	void CommitDbTransaction(const long, string&, string&);
	void RollbackDbTransaction(const long, string&, string&);
#import

//--------------------------------------------------------------------
/// \brief  \~russian ������������, �������������� ������� �������� ����������
///         \~english Enumeration that represents transaction isolation level
enum ENUM_DBTRAN_ISOLATION_LEVEL
{
    TRANLEVEL_CHAOS = 0x10,
    TRANLEVEL_READCOMMITED = 0x1000,
    TRANLEVEL_READUNCOMMITED = 0x100,
    TRANLEVEL_REPETABLEREAD = 0x10000,
    TRANLEVEL_SERIALIZABLE = 0x100000,
    TRANLEVEL_SNAPSHOT = 0x1000000,
    TRANLEVEL_UNSPECIFIED = -1
};

//--------------------------------------------------------------------
/// \brief  \~russian ����� ����������
///         \~english Represents transaction
class CDbTransaction : public CClrObject
{
public:
   /// \brief  \~russian ����������� ������
   ///         \~english constructor
   CDbTransaction() { MqlTypeName("CDbTransaction"); }

// methods 

   /// \brief  \~russian ������������ ����������
   ///         \~english Commits current transaction
   void Commit();
   /// \brief  \~russian ������ ����� ����������
   ///         \~english Rollbacks current transaction
   void Rollback();
};

//--------------------------------------------------------------------
void CDbTransaction::Commit(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   CommitDbTransaction(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("Commit", exType, exMsg);
}

//--------------------------------------------------------------------
CDbTransaction::Rollback(void)
{
   string exType = "", exMsg = "";
   StringInit(exType, 64);
   StringInit(exMsg, 256);
   
   RollbackDbTransaction(ClrHandle(), exType, exMsg);
   
   if (exType != "") 
      OnClrException("Commit", exType, exMsg);
}
