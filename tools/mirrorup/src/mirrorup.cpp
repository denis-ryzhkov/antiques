#define UNICODE
#define _UNICODE

#include <windows.h>
#include <stdio.h>
#include <time.h>
#include <tchar.h>
#include <locale.h>

DWORD okCount = 0, errCount = 0;
#define BUF_LEN ( MAX_PATH * 4 )

bool unprotect( TCHAR* fileName ) {
 bool result = true;
 DWORD fileAttrs = GetFileAttributes( fileName );
 if ( fileAttrs & FILE_ATTRIBUTE_READONLY )
  result = SetFileAttributes( fileName, fileAttrs - FILE_ATTRIBUTE_READONLY );
 if ( fileAttrs & FILE_ATTRIBUTE_DIRECTORY )
  result = RemoveDirectory( fileName );
 return result;
}

void mirrorup( TCHAR* fromPath, TCHAR* toPath, bool reverseClean = false ) {
 if ( !reverseClean ) mirrorup( toPath, fromPath, true );

 WIN32_FIND_DATA fromFindData, toFindData;
 TCHAR fromMask[ BUF_LEN ]; bool ok;
 _stprintf( fromMask, _T("%s\\*"), fromPath );

 HANDLE fromFind = FindFirstFile( fromMask, &fromFindData );
 if ( fromFind == INVALID_HANDLE_VALUE ) return;
 do {
 
  if ( !_tcscmp( fromFindData.cFileName, _T(".")) ||
       !_tcscmp( fromFindData.cFileName, _T(".."))) continue;

  bool isDir = ( fromFindData.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY );
  TCHAR fromFileName[ BUF_LEN ], toFileName[ BUF_LEN ];
  _stprintf( fromFileName, _T("%s\\%s"), fromPath, fromFindData.cFileName );
  _stprintf( toFileName, _T("%s\\%s"), toPath, fromFindData.cFileName );
  HANDLE toFind = FindFirstFile( toFileName, &toFindData );
  bool toFound = ( toFind != INVALID_HANDLE_VALUE );

  if ( reverseClean ) {
   if ( isDir ) mirrorup( fromFileName, toFileName, reverseClean );

   if ( !toFound ) {
    ok = unprotect( fromFileName );
    if ( !isDir ) ok = ok && DeleteFile( fromFileName );
    if ( ok ) okCount++; else errCount++;
    _tprintf( _T("%s) delete %s\n"), ( ok? _T("+") : _T("-")), fromFileName );
   }
  
  } else { // not reverseClean

   if ( !toFound || !isDir && (
     fromFindData.nFileSizeHigh != toFindData.nFileSizeHigh ||
     fromFindData.nFileSizeLow != toFindData.nFileSizeLow ||
     CompareFileTime( &fromFindData.ftLastWriteTime,
                      &toFindData.ftLastWriteTime ))) {

    if ( toFound ) unprotect( toFileName );

    if ( ok = ( isDir ?
      CreateDirectoryEx( fromFileName, toFileName, 0 ) :
      CopyFile( fromFileName, toFileName, 0 )))
     okCount++; else errCount++;
    _tprintf( _T("%s) copy %s\n"), ( ok? _T("+") : _T("-")), fromFileName );
   }

   if ( isDir ) mirrorup( fromFileName, toFileName, reverseClean );
  }

  if ( toFound ) FindClose( toFind );
 } while ( FindNextFile( fromFind, &fromFindData ));
 FindClose( fromFind );
}

TCHAR* unslash( TCHAR* path ) {
 TCHAR* endOfPath = path + _tcslen( path ) - 1;
 if ( *endOfPath == _T('\\')) *endOfPath = _T('\0');
 return path;
}

TCHAR* timestamp( TCHAR* dateTimeStr ) {
 time_t dateTime; 
 time( &dateTime );
 _tcsftime( dateTimeStr, BUF_LEN, _T("---%Y-%m-%d--%H-%M-%S"),
  localtime( &dateTime ));
 return dateTimeStr;
}

int _tmain( int argc, TCHAR* argv[]) {

 _tsetlocale( LC_ALL, _T(""));

 if ( argc != 3 ) {
  _putts(
   _T("mirrorup, version 1.5 2008-01-17--2008-02-26 (c) Denis Ryzhkov\n")
   _T("http://denis.ryzhkov.org/?soft/mirrorup\n")
   _T("\n")
   _T("usage: mirrorup C:\\proj U:\\proj\n")
   _T("\n")
   _T("means: make a mirror backup of C:\\proj to U:\\proj\n")
   _T("i.e. copy or delete only files and folders\n")
   _T("that were changed after previous backup.\n")
   _T("file size and modification time are only compared.\n")
   _T("\n")
   _T("source code and batch script provided."));
  return 0;
 }

 TCHAR* fromPath = unslash( argv[1]);
 TCHAR* toPath = unslash( argv[2]);
 TCHAR dateTimeStr[ BUF_LEN ];
 _tprintf( _T("\n%s make a mirror backup of %s to %s\n\n"),
  timestamp( dateTimeStr ), fromPath, toPath );

 #define attrErr 0xFFFFFFFF
 if ( GetFileAttributes( toPath ) == attrErr )
  CreateDirectoryEx( fromPath, toPath, 0 );
 if ( GetFileAttributes( toPath ) == attrErr ) {
  _putts( _T("bad path"));
  return 1;
 }

 mirrorup( fromPath, toPath );

 _tprintf( _T("\n%s done ok: %d, errors: %d\n"),
  timestamp( dateTimeStr ), okCount, errCount );
 return 0;
}
