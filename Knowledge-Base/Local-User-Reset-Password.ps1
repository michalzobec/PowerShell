$Password = "1PurpleAppleAndRandom.+"
$NewPassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
Set-LocalUser -Name Example -Password $NewPassword
