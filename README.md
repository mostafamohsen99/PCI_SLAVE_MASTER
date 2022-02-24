# PCI_SLAVE_MASTER
PCI Target Slave, which Receives command from Master and recognize it’s Address and it’s type
read or write, DEVSEL and TRDY should be configured properly ,when command is read the Target
Device should start sending out a frame up on having a Frame signal asserted to low, if it’s write the
target should save the Data on it’s available location using (BE) byte enable, the target Device
should stop when Frame Asserted to High.
