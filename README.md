# workspace

## Clone the workspace 
run the below command to clone the workspace with access token 
```
export GIT_TOKEN=<your_token_here>
git clone https://$GIT_TOKEN@github.com/vishnu-vidyesh/workspace.git
```

## Install nessesary tools
run the script to install required tools
```
sudo apt update
chmod +x ./tools/install.sh
sudo ./tools/install.sh
```

## Tool Commands
Create Object and ELF File 
```
riscv64-unknown-elf-gcc -o hello.elf hello.c
```
Create Hex file
```
riscv64-unknown-elf-objcopy -O ihex hello.elf hello.hex
```

