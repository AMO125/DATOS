/*R2-Dato: ddl_metro
Creamos las relaciones necesarias con sus respectivas pk y fk.
Se optó por la política de mantenimiento de fk cascade.
Para un funcionamiento adecuado, consideramos la mayoría de datos como obligatorios.*/

--La tabla estación con restricción de no. de estación válido y tel de 10 caracteres numéricos.
CREATE table Estacion(
NumeroEstacion int not null,
JefeEstacion varchar(150) not null,
NombreEstacion varchar(100) not null,
HoraApertura Time not null,
HoraCierre Time not null,
Telefono char(10) not null,
constraint pkEstacion primary key (NumeroEstacion),
constraint validNumeroEstacion check (NumeroEstacion between 1 and 195),
constraint validTelefono check (Telefono ~ '^[0-9]{10}$')
);

--La tabla acceso con horarios predeterminados y validación de numero de acceso.
CREATE table Acceso(
NumeroAcceso int not null,
NumeroEstacion int not null,
HoraApertura time DEFAULT '5:00:00.000',
HoraCierre time DEFAULT '0:00:00.000',
constraint pkAcceso primary key(NumeroAcceso),
constraint fkAcceso foreign key(NumeroEstacion) references Estacion(NumeroEstacion)
on update cascade on delete cascade,
constraint validNumeroAcceso check (NumeroAcceso >0)
);

--La tabla conductor con validación de mayoría de edad y saldo en un rango determinado.
CREATE table Conductor(
CURP char(18) not null,
Nombre varchar(100) not null,
Paterno varchar(100) not null,
Materno VARCHAR(100) not null,
Sexo char(1),
Salario numeric(10,2),
Nacimiento date not null,
Estado varchar(100) not null,
constraint pkConductor primary key (CURP),
constraint validSexo check (Sexo in ('M', 'F')),
constraint validNacimiento check (extract (years from age(current_date, Nacimiento))>=18),
constraint validSalario check (Salario between 6000 and 50000)
);

--La tabla línea con validación de no. de línea.
CREATE table Linea(
NumeroLinea int,
NombreLinea varchar(100) not null,
constraint pkLinea primary key (NumeroLinea),
constraint validNumeroLinea check (NumeroLinea between 1 and 12)
);

CREATE table Pertenecer(
NumeroLinea int not null,
NumeroEstacion int not null,
constraint fk1Pertenecer foreign key(NumeroLinea) references Linea(NumeroLinea)
on update cascade on delete cascade,
constraint fk2Pertenecer foreign key(NumeroEstacion) 
references Estacion(NumeroEstacion)
on update cascade on delete cascade
);

CREATE table Telefono(
CURP char(18),
Telefono char(10),
constraint pkTelefono primary key(Telefono),
constraint fkTelefono foreign key(CURP) references Conductor (CURP)
on update cascade on delete cascade,
constraint validTelefono check (Telefono ~ '^[0-9]{10}$')
);

--La tabla tren con validación de no. vagones y año de fabricación posterior al año de los 
--primeros trenes de la CDMX
CREATE table Tren(
IDTren int,
NumeroLinea int not null,
Marca varchar(100) not null,
Estatus boolean not null default TRUE, 
Vagones int not null,
AnoFabrica INT not null,
constraint pkTren primary key (IDTren),
constraint fkTrenLinea foreign key (NumeroLinea) REFERENCES Linea(NumeroLinea)
on update cascade on delete cascade,
constraint validVagones check(Vagones>0),
constraint validAnoFabrica check (AnoFabrica between 1968 AND extract(year from current_Date))
);

--La tabla conducir con validación de turno matutino o vespertino.
CREATE TABLE Conducir(
IDTren int not null,
CURP CHAR(18) not null,
HoraInicio Time not null,
HoraFin Time not null,
Fecha Date not null,
Turno CHAR(1) not null,
constraint fkConducirTren foreign key (IDTren) references Tren(IDTren)
on update cascade on delete cascade,
constraint fkConducirConductor foreign key (CURP) references Conductor(CURP)
on update cascade on delete cascade,
constraint validTurno check (lower(Turno) in ('m', 'v'))  
);

--La tabla hangar con la validación del ID
CREATE table Hangar(
IDHangar int, 
NumeroEstacion int not null,
constraint pkHangar primary key (IDHangar),
constraint fkHangar foreign key(NumeroEstacion) references Estacion(NumeroEstacion)
on update cascade on delete cascade,
constraint validIDHangar check (IDHangar >0)
);

--La tabla reservar con validación de reservas posteriores al inicio de 
--las operaciones del metro CDMX. La fecha de fin no es obligatoria al poder existir 
--trenes que continuan en reserva sin fecha asignada de fin.
CREATE table Reservar(
IDTren int not null,
IDHangar int not null,
FechaInicio Date not null,
FechaFin Date, 
constraint fkReservarTren foreign key (IDTren) references Tren(IDTren)
on update cascade on delete cascade,
constraint fkReservarHangar foreign key (IDHangar) references Hangar(IDHangar)
on update cascade on delete cascade,
constraint validFechaInicio check (extract (years from(FechaInicio)) between 1969 and 
		   extract (years from(current_date))),
constraint validFechaFin check (FechaInicio <= FechaFin)
);

--La tabla servicio con validación de ID
CREATE table Servicio(
IDServicio int,
NombreServicio varchar(100) not null,
Tipo varchar(100) not null,
constraint pkServicio primary key(IDServicio),
constraint validIDServicio check(IDServicio >0)
);

CREATE table Conectar(
NumeroEstacion int not null,
IDServicio int not null,
constraint fk1Conectar foreign key(NumeroEstacion) references Estacion(NumeroEstacion)
on update cascade on delete cascade,
constraint fk2Conectar foreign key(IDServicio) references Servicio(IDServicio)
on update cascade on delete cascade
);
