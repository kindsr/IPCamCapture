unit uVersionInfo;

interface

uses
  Windows, Forms, SysUtils;

type
  TVerKind = (
    tvComments,         // 코멘트
    tvCompanyName,      // 회사명
    tvFileDescription,  // 설명
    tvFileVersion,      // 파일버젼
    tvInternalName,     // 내부명
    tvLegalCopyright,   // 저작권
    tvLegalTrademarks,  // 상표
    tvOriginalFilename, // 정식파일명
    tvPrivateBuild,     // Private Build
    tvProductName,      // 제품명
    tvProductVersion,   // 제품버젼
    tvSpecialBuild);    // Special Build

    function fnGetVersionInfo(KeyWord: TVerKind): string;

const
  csVerKey: array [TVerKind] of String = (
        'Comments',
        'CompanyName',
        'FileDescription',
        'FileVersion',
        'InternalName',
        'LegalCopyright',
        'LegalTrademarks',
        'OriginalFilename',
        'PrivateBuild',
        'ProductName',
        'ProductVersion',
        'SpecialBuild');

implementation

// 버젼 정보 얻기
function fnGetVersionInfo(KeyWord: TVerKind): string;
const
  cTranslation = '\VarFileInfo\Translation';
  cFileInfo = '\StringFileInfo\%0.4s%0.4s\';
var
  dBufSize    : DWORD;
  dHWnd       : DWORD;
  pVerInfoBuf : Pointer;
  pVerData    : Pointer;
  lVerDataLen : Longword;
  sPath       : String;
begin

  // 필요한 버퍼 사이즈 얻기
  dBufSize := GetFileVersionInfoSize(PChar(Application.ExeName), dHWnd);

  if dBufSize <> 0 then
  begin
    // 메모리확보
    GetMem(pVerInfoBuf, dBufSize);

    try
      GetFileVersionInfo(PChar(Application.ExeName), 0, dBufSize, pVerInfoBuf);

      // 변수정보 블럭안의 변환 테이블 지정
      VerQueryValue(pVerInfoBuf, PChar(cTranslation), pVerData, lVerDataLen);

      if not (lVerDataLen > 0) then
        raise Exception.Create('정보 수집 실패');

      // 8자리 16진수로 변환
      // →'\StringFileInfo\027382\FileDescription'
      sPath := Format(cFileInfo + csVerKey[KeyWord],
                      [IntToHex(Integer(pVerData^) and $FFFF, 4),
                      IntToHex((Integer(pVerData^) shr 16) and $FFFF, 4)]);
      VerQueryValue(pVerInfoBuf, PChar(sPath), pVerData, lVerDataLen);

      if lVerDataLen > 0 then
      begin
        // VerData는 제로로 끝나는 문자열이 아닌 것에 주의
        result := '';
        SetLength(result, lVerDataLen);
        StrLCopy(PChar(result), pVerData, lVerDataLen);
      end;
    finally
      // 개방
      FreeMem(pVerInfoBuf);
    end;
  end;
end;

end.
