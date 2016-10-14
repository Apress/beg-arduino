/*
SCP1000             Mega
DRDY                N/A
CSB                 53 via Logic Level Convertor
MISO                50 (straight through)
MOSI                51 via Logic Level Convertor
SCK                 52 via Logic Level Convertor
3.3v                3.3v
GND                 GND
TRIG                GND
PD                  GND
*/

// SPI PINS
#define SLAVESELECT 53
#define SPICLOCK 52
#define DATAOUT 51  //MOSI
#define DATAIN 50   //MISO
#define UBLB(a,b)  ( ( (a) << 8) | (b) )
#define UBLB19(a,b) ( ( (a) << 16 ) | (b) )

//Addresses
#define PRESSURE 0x1F   //Pressure 3 MSB
#define PRESSURE_LSB 0x20 //Pressure 16 LSB
#define TEMP 0x21       //16 bit temp

char rev_in_byte;
int temp_in;
unsigned long pressure_lsb;
unsigned long pressure_msb;
unsigned long temp_pressure;
unsigned long pressure;

void setup()
{
        byte clr;
        pinMode(DATAOUT, OUTPUT);
        pinMode(DATAIN, INPUT);
        pinMode(SPICLOCK, OUTPUT);
        pinMode(SLAVESELECT, OUTPUT);
        digitalWrite(SLAVESELECT, HIGH); //disable device

        SPCR = B01010011; // SPi Control Register
        //MPIE=0, SPE=1 (on), DORD=0 (MSB first), MSTR=1 (master), CPOL=0 (clock idle when
 low), CPHA=0 (samples MOSI on rising edge), SPR1=0 & SPR0=0 (500kHz)
        clr=SPSR; // SPi Status Register
        clr=SPDR; // SPi Data Register
        delay(10);
        Serial.begin(38400);
        delay(500);

        write_register(0x03,0x09); // High Speed Read Mode
        write_register(0x03,0x0A); // High Resolution Measurement Mode
}

void loop()
{
        pressure_msb = read_register(PRESSURE);
        pressure_msb &= B00000111;
        pressure_lsb = read_register16(PRESSURE_LSB);
        pressure_lsb &= 0x0000FFFF;
        pressure = UBLB19(pressure_msb, pressure_lsb);
        pressure /= 4;
        Serial.print("Pressure (hPa): ");
        float hPa = float(pressure)/100;
        Serial.println(hPa);

        Serial.print("Pressure (Atm): ");
        float pAtm = float(pressure)/101325.0;
        Serial.println(pAtm, 3);

        temp_in = read_register16(TEMP);
        float tempC = float(temp_in)/20.0;
        Serial.print("Temp. C: ");
        Serial.println(tempC);
        float tempF = (tempC*1.8) + 32;
        Serial.print("Temp. F: ");
        Serial.println(tempF);
        Serial.println();
        delay(1000);
}

char spi_transfer(char data)
{
        SPDR = data;                     // Start transmission
        while (!(SPSR & (1<<SPIF))) { }; // Wait for transmission end
        return SPDR;                     // return the received byte
}

char read_register(char register_name)
{
        char in_byte;
        register_name <<= 2;
        register_name &= B11111100; //Read command

        digitalWrite(SLAVESELECT, LOW); //Enable SPI Device
        spi_transfer(register_name); //Write byte to device
        in_byte = spi_transfer(0x00); //Send nothing but get back register value
        digitalWrite(SLAVESELECT, HIGH); // Disable SPI Device
        delay(10);
        return(in_byte); // return value
}

unsigned long read_register16(char register_name)
{
        byte in_byte1;
        byte in_byte2;
        float in_word;

        register_name <<= 2;
           register_name &= B11111100; //Read command

        digitalWrite(SLAVESELECT, LOW); //Enable SPI Device
        spi_transfer(register_name); //Write byte to device
        in_byte1 = spi_transfer(0x00);
        in_byte2 = spi_transfer(0x00);
        digitalWrite(SLAVESELECT, HIGH); // Disable SPI Device
        in_word = UBLB(in_byte1,in_byte2);
        return(in_word); // return value
}

void write_register(char register_name, char register_value)
{
        register_name <<= 2;
        register_name |= B00000010; //Write command

        digitalWrite(SLAVESELECT, LOW); //Select SPI device
        spi_transfer(register_name); //Send register location
        spi_transfer(register_value); //Send value to record into register
        digitalWrite(SLAVESELECT, HIGH);
}

