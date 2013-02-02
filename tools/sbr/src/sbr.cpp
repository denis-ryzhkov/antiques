#include <windows.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define STR_LEN 512
#define DAYS_AHEAD 6
char const * const appTitle = "Simple Birthday Reminder";

struct Item {
 int day;
 int month;
 int year;
 char title[ STR_LEN ];
} *items = 0;

int cry( char const * const reason, char const * const object = "" ) {
 char message[ STR_LEN ];
 sprintf( message, "%s\n%s", reason, object );
 MessageBox( 0, message, appTitle,
   MB_SYSTEMMODAL | MB_SETFOREGROUND | MB_ICONSTOP | MB_OK );
 free( items );
 return 1;
}

int itemCompare( const Item* item1, const Item* item2 ) {
 if ( item1->month != item2->month ) return item1->month - item2->month;
 if ( item1->day != item2->day ) return item1->day - item2->day;
 if ( item1->year != item2->year ) return item1->year - item2->year;
 return strcmp( item1->title, item2->title );
}

int WINAPI WinMain( HINSTANCE hInstance, HINSTANCE hPrevInstance,
  LPSTR lpszCmdLine, int nCmdShow ) {

//// read database

 char path[ STR_LEN ];
 GetModuleFileName( GetModuleHandle( 0 ), path, STR_LEN );
 strrchr( path, '\\' )[ 1 ] = 0;
 char dbFileName[ STR_LEN ]; sprintf( dbFileName, "%sdb.txt", path );
 char tempFileName[ STR_LEN ]; sprintf( tempFileName, "%sdb.tmp", path );
 FILE* dbFile = fopen( dbFileName, "r" );
 if ( !dbFile ) {
  dbFile = fopen( dbFileName, "w" );
  if ( !dbFile ) return cry( "Can't read and write database file", dbFileName );
  fclose( dbFile );
  dbFile = fopen( dbFileName, "r" );
 }
 int itemsCount = 0, charIndex = 0;
 bool hasLines = false, hasBadLines = false;
 char line[ STR_LEN ];
 while ( fgets( line, STR_LEN, dbFile )) {
  hasLines = true;
  int lineEnd = strlen( line ) - 1;
  if ( lineEnd >= 0 && line[ lineEnd ] == '\n' ) line[ lineEnd ] = 0;
  items = ( Item* ) realloc( items, sizeof( Item ) * ++itemsCount );
  Item& item = items[ itemsCount - 1 ];
  charIndex = item.day = item.month = item.year = 0;
  sscanf( line, "%2d.%2d.%4d %n",
    &item.day, &item.month, &item.year, &charIndex );
  strcpy( item.title, line + charIndex );
  if ( !charIndex ) hasBadLines = true;
 }
 fclose( dbFile );

//// sort database

 qsort( items, itemsCount, sizeof( Item ),
   ( int ( __cdecl* )( const void*, const void* )) itemCompare );

//// write database 

 FILE* tempFile = fopen( tempFileName, "w" );
 if ( !tempFile )
  return cry( "Can't write temporary database file", tempFileName );
 SetFileAttributes( tempFileName, FILE_ATTRIBUTE_HIDDEN );
 int itemIndex;
 for ( itemIndex = 0; itemIndex < itemsCount; itemIndex++ ) {
  Item& item = items[ itemIndex ];
  fprintf( tempFile, "%02d.%02d.%04d %s\n",
    item.day, item.month, item.year, item.title );
 }
 fclose( tempFile );
 if ( remove( dbFileName ))
  return cry( "Can't swap database file", tempFileName );
 rename( tempFileName, dbFileName );
 SetFileAttributes( dbFileName, FILE_ATTRIBUTE_ARCHIVE );

//// show active birthdays

 char message[ STR_LEN * 4 ] = "";
 if ( !hasLines ) strcat( message, "Database file is empty.\n" );
 else if ( hasBadLines )
  strcat( message, "Bad lines found in database file.\n" );
 bool hasActiveItems = false;
 SYSTEMTIME now;
 GetLocalTime( &now );
 for ( itemIndex = 0; itemIndex < itemsCount; itemIndex++ ) {
  Item& item = items[ itemIndex ];
  bool hasActiveItem = false;
  if ( item.month == now.wMonth ) {
   int dayDelta = item.day - now.wDay;
   if ( dayDelta >= 0 && dayDelta <= DAYS_AHEAD ) hasActiveItem = true;
  } else if ( item.month - now.wMonth % 12 == 1 &&
     item.day + ( 28 - now.wDay ) <= DAYS_AHEAD ) hasActiveItem = true;
  if ( hasActiveItem ) {
   hasActiveItems = true;
   char submessage[ STR_LEN ];
   sprintf( submessage, "%02d.%02d ", item.day, item.month );
   strcat( message, submessage );
   if ( item.year ) {
    sprintf( submessage, "(%d years) ", now.wYear - item.year );
    strcat( message, submessage );
   }
   strcat( message, item.title );
   strcat( message, "\n" );
 }}
 free( items );

 if ( !strlen( lpszCmdLine ) && !hasActiveItems && hasLines && !hasBadLines )
  strcat( message, "No coming birthdays found.\n" );
 if ( strlen( message )) {
  strcat( message, "\nDo you want to edit database file?" );
  if ( MessageBox( 0, message, appTitle, MB_SYSTEMMODAL | MB_SETFOREGROUND |
    MB_ICONINFORMATION | MB_YESNO |
    ( ( hasLines && !hasBadLines )? MB_DEFBUTTON2 : MB_DEFBUTTON1 )) == IDYES )
   ShellExecute( 0, 0, dbFileName, 0, 0, SW_SHOW );
 }

 return 0;
}
