echo "Beginning toolchain installation"

# Define installation directory
TOOLCHAIN_DIR="/home/tools"

# Create the tools directory if it doesn't exist
mkdir -p $TOOLCHAIN_DIR

# Install necessary packages
sudo apt-get install vim -y
sudo apt-get install autoconf -y
sudo apt-get install automake -y
sudo apt-get install autotools-dev -y
sudo apt-get install curl -y
sudo apt-get install libmpc-dev libmpfr-dev libgmp-dev -y
sudo apt-get install gawk -y
sudo apt-get install build-essential -y
sudo apt-get install bison flex -y
sudo apt-get install texinfo gperf -y
sudo apt-get install -y
sudo apt-get install patchutils bc -y
sudo apt-get install zlib1g-dev libexpat1-dev -y
sudo apt-get install git -y
sudo apt-get install gtkwave -y

# Download and extract RISC-V GCC toolchain
cd $TOOLCHAIN_DIR
wget "https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz"
tar -xvzf riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz

# Add the toolchain binary path to the environment
export PATH=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:$PATH

# Install Device Tree Compiler
sudo apt-get install device-tree-compiler -y

# Clone and build RISC-V ISA Simulator
git clone https://github.com/riscv/riscv-isa-sim.git
cd riscv-isa-sim/
mkdir build
cd build
../configure --prefix=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14
make -j 4
sudo make install

# Clone and build RISC-V Proxy Kernel (riscv-pk)
cd $TOOLCHAIN_DIR
git clone https://github.com/riscv/riscv-pk.git
cd riscv-pk/
mkdir build
cd build/
../configure --prefix=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14 --host=riscv64-unknown-elf
make -j 4
sudo make install

# Update environment variables for RISC-V tools
export PATH=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:$PATH

# Clone and build Icarus Verilog
cd $TOOLCHAIN_DIR
git clone https://github.com/steveicarus/iverilog.git
cd iverilog/
git checkout --track -b v10-branch origin/v10-branch
git pull
chmod 777 autoconf.sh
./autoconf.sh
./configure
make -j 4
sudo make install

# Update .bashrc with new toolchain paths
echo "export PATH=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/bin:\$PATH" >> ~/.bashrc
echo "export PATH=$TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14/riscv64-unknown-elf/bin:\$PATH" >> ~/.bashrc

# Reload .bashrc to apply changes
source ~/.bashrc
echo "Clean Up"
echo "Removing riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz"
rm $TOOLCHAIN_DIR/riscv64-unknown-elf-gcc-8.3.0-2019.08.0-x86_64-linux-ubuntu14.tar.gz
echo "Done with toolchain installation!"

bash setup_ocr.sh
