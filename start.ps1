## Requires presence of Red Hat certificates in A:\, these can be extracted from cat files in virtio drivers iso
## These need to be imported first otherwise Windows will complain about unsigned drivers
$virtio_drive = (Get-WmiObject win32_cdromdrive|Where-Object { $_.volumename -like 'virtio-win*' }).drive
$driver_path = (Get-ChildItem -Path $virtio_drive -Recurse -Include "*.inf").FullName

Import-Certificate -FilePath A:\redhat1.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
Import-Certificate -FilePath A:\redhat2.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
Import-Certificate -FilePath A:\redhat3.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher
Import-Certificate -FilePath A:\redhat4.cer -CertStoreLocation Cert:\LocalMachine\TrustedPublisher

ForEach ($driver in $driver_path) {
    pnputil -i -a $driver
}
