CREATE TABLE supplier
(
    cd_supplier NUMBER(5,0) NOT NULL,
    supplier VARCHAR2(100) NOT NULL,
    supplier_short VARCHAR2(20),
    CONSTRAINT supplier_pk PRIMARY KEY (cd_supplier),
    CONSTRAINT supplier_supplier_un UNIQUE (supplier),
    CONSTRAINT supplier_supplier_short UNIQUE (supplier_short)
);

/* TRIGGER and SEQUENCE TO MAKE cd_supplier as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_supplier_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_supplier_seq_tr
    BEFORE INSERT ON supplier FOR EACH ROW
WHEN (NEW.cd_supplier IS NULL OR NEW.cd_supplier = 0)
BEGIN
    SELECT cd_supplier_seq.NEXTVAL INTO :NEW.cd_supplier FROM dual;
END;
COMMENT ON COLUMN supplier.cd_supplier IS 'Identificador del proveedor (variable autoincremental manejada por trigger';
COMMENT ON COLUMN supplier.supplier IS 'Nombre completo del proveedor';
COMMENT ON COLUMN supplier.supplier_short IS 'Abreviación del proveedor';

CREATE TABLE model
(
    cd_model NUMBER(5,0) NOT NULL,
    cd_supplier NUMBER(5,0) NOT NULL,
    model VARCHAR2(300) NOT NULL,
    model_short VARCHAR2(20),
    CONSTRAINT model_pk PRIMARY KEY (cd_model),
    CONSTRAINT model_supplier_fk FOREIGN KEY (cd_supplier) REFERENCES supplier(cd_supplier),
    CONSTRAINT model_model_un UNIQUE (model),
    CONSTRAINT model_model_short UNIQUE (model_short)
);

/* TRIGGER and SEQUENCE TO MAKE cd_model as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_model_seq START WITH 1 INCREMENT BY 1 ;
CREATE OR REPLACE TRIGGER cd_model_seq_tr
    BEFORE INSERT ON model FOR EACH ROW
WHEN (NEW.cd_model IS NULL OR NEW.cd_model = 0)
BEGIN
    SELECT cd_model_seq.NEXTVAL INTO :NEW.cd_model FROM dual;
END;

COMMENT ON COLUMN model.cd_model IS 'Identificador del modelo (variable autoincremental manejada por trigger';
COMMENT ON COLUMN model.cd_supplier IS 'Identificador del proveedor';
COMMENT ON COLUMN model.model IS 'Nombre completo del modelo';
COMMENT ON COLUMN model.model_short IS 'Abreviación del modelo';

CREATE TABLE tracker
(
    cd_tracker NUMBER(10,0) NOT NULL,
    supplier_id VARCHAR(150) NOT NULL,
    serial VARCHAR(50),
    movebank_tag VARCHAR(150) NOT NULL,
    cd_model NUMBER(5,0) NOT NULL,
    CONSTRAINT tracker_pk PRIMARY KEY (cd_tracker),
    CONSTRAINT tracker_model_cd_model_fk FOREIGN KEY (cd_model) REFERENCES model(cd_model),
    CONSTRAINT tracker_supplier_id_model_un UNIQUE (supplier_id, cd_model),
    CONSTRAINT tracker_movebank_tag_un UNIQUE (movebank_tag)
);

/* TRIGGER and SEQUENCE TO MAKE cd_tracker as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_tracker_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_tracker_seq_tr
    BEFORE INSERT ON tracker FOR EACH ROW
WHEN (NEW.cd_tracker IS NULL OR NEW.cd_tracker = 0)
BEGIN
    SELECT cd_tracker_seq.NEXTVAL INTO :NEW.cd_tracker FROM dual;
END;

COMMENT ON COLUMN tracker.cd_tracker IS 'Identificador del tracker (variable autoincremental manejada por trigger)';
COMMENT ON COLUMN tracker.supplier_id IS 'Identificador del tracker en el sistema de identificación de los proveedores de los equipos tracker';
COMMENT ON COLUMN tracker.serial IS 'Numero serial de identificación de los equipos';
COMMENT ON COLUMN tracker.movebank_tag IS 'Tag (identificador de tracker) en el sistema de movebank.org';
COMMENT ON COLUMN tracker.cd_model IS 'Foreign key hacía la tabla de modelos que permite recuperar las informaciones sobre modelos y proveedores de los trackers';

CREATE TABLE taxon
(
    cd_taxon NUMBER(5,0) NOT NULL,
    scientific_name VARCHAR2(100) NOT NULL,
    kingdom VARCHAR2(50),
    phylum VARCHAR2(50),
    "CLASS" VARCHAR2(50),
    "ORDER" VARCHAR2(50),
    family VARCHAR2(50),
    genus VARCHAR2(50),
    specific_epithet VARCHAR2(50),
    itis_tsn NUMBER (20,0),
    CONSTRAINT taxon_pk PRIMARY KEY (cd_taxon),
    CONSTRAINT taxon_un UNIQUE (kingdom, phylum, "CLASS", "ORDER", family, genus, specific_epithet),
    CONSTRAINT taxon_sci_name_un UNIQUE (scientific_name)
);

/* TRIGGER and SEQUENCE TO MAKE cd_tracker as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_taxon_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_taxon_seq_tr
    BEFORE INSERT ON taxon FOR EACH ROW
WHEN (NEW.cd_taxon IS NULL OR NEW.cd_taxon = 0)
BEGIN
    SELECT cd_taxon_seq.NEXTVAL INTO :NEW.cd_taxon FROM dual;
END;


COMMENT ON COLUMN taxon.cd_taxon IS 'Identificador del taxon (autoincremental, interno a la base de datos)';
COMMENT ON COLUMN taxon.scientific_name IS 'Identificador del taxon (autoincremental, interno a la base de datos)';
COMMENT ON COLUMN taxon.kingdom IS 'Reino taxonómico al que pertenece la especie rastreada (Animalia)';
COMMENT ON COLUMN taxon.phylum IS 'Filo taxonómico al que pertenece la especie rastreada (Chordata)';
COMMENT ON COLUMN taxon."CLASS" IS 'Clase taxonómica al que pertenece la especie rastreada (Aves, Mammalia)';
COMMENT ON COLUMN taxon."ORDER" IS 'Orden taxonómico al que pertenece la especie rastreada (Strigiformes, Pelecaniformes, Falconiformes, Galliformes, Accipitriformes, Primates, Rodentia, Carnivora, Didelphimorphia)';
COMMENT ON COLUMN taxon.family IS 'Familia taxonómica al que pertenece la especie rastreada (Strigidae, Ardeidae, Threskiornithidae, Falconidae, Cracidae, Accipitridae, Callitrichidae, Sciuridae, Canidae, Didelphidae, Mustelidae, Dasyproctidae, Felidae)';
COMMENT ON COLUMN taxon.genus IS 'Género taxonómico al que pertenece la especie rastreada (Asio, Bubulcus, Phimosus, Milvago, Ortalis, Rupornis, Saguinus, Notosciurus, Cerdocyon, Didelphis, Mustela, Dasyprocta, Puma, Leopardus)';
COMMENT ON COLUMN taxon.specific_epithet IS 'Epíteto específico de la especie rastreada (clamator, ibis, infuscatus, chimachima, columbiana, magnirostris, leucopus, granatensis, thous, marsupialis, frenata, punctata, concolor, tigrinus)';
COMMENT ON TABLE taxon IS 'Información taxonomica';


CREATE TABLE life_stage
(
    cd_life_stage NCHAR(3),
    life_stage VARCHAR2(50),
    CONSTRAINT life_stage_pk PRIMARY KEY (cd_life_stage),
    CONSTRAINT life_stage_un UNIQUE (life_stage)
);

COMMENT ON COLUMN life_stage.cd_life_stage IS 'Codigo interno a la base de datos para manejar los estadios de vida de los individuos';
COMMENT ON COLUMN life_stage.life_stage IS 'Estadio de vida en palabras completas';
COMMENT ON TABLE life_stage IS 'Tabla de control de las categorías de estadio de vida (permite, gracias a una FOREIGN KEY, controlar los valores entrados en la tabla de descripción de los individuos)';

CREATE TABLE individual
(
    cd_individual NUMBER(10,0) NOT NULL,
    nick_name VARCHAR2(100) NOT NULL,
    movebank_animal_id VARCHAR2(60) NOT NULL,
    cd_taxon NUMBER(5,0) NOT NULL,
    sex VARCHAR2(50),
    cd_life_stage NCHAR(3),
    CONSTRAINT individual_pk PRIMARY KEY (cd_individual),
    CONSTRAINT individual_nick_name_un UNIQUE (nick_name),
    CONSTRAINT individual_movebank_animal_id_un UNIQUE (movebank_animal_id),
    CONSTRAINT individual_cd_taxon_fk FOREIGN KEY (cd_taxon) REFERENCES taxon(cd_taxon),
    CONSTRAINT individual_cd_life_stage_fk FOREIGN KEY (cd_life_stage) REFERENCES life_stage(cd_life_stage),
    CONSTRAINT individual_sex_ck CHECK (sex IN ('male', 'female', 'unknown'))
);

/* TRIGGER and SEQUENCE TO MAKE cd_taxon as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_individual_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_individual_seq_tr
    BEFORE INSERT ON individual FOR EACH ROW
WHEN (NEW.cd_individual IS NULL OR NEW.cd_taxon = 0)
BEGIN
    SELECT cd_individual_seq.NEXTVAL INTO :NEW.cd_individual FROM dual;
END;

COMMENT ON COLUMN individual.cd_individual IS 'Identificador del individuo (autoincremental)';
COMMENT ON COLUMN individual.nick_name IS 'Apodo del individuo';
COMMENT ON COLUMN individual.movebank_animal_id IS 'Identificador del animal (del individuo) en movebank.org';
COMMENT ON COLUMN individual.cd_taxon IS 'Codigo taxonomico del individuo (ver tabla taxon)';
COMMENT ON COLUMN individual.sex IS 'Sexo del individuo (male, female or unknown)';
COMMENT ON COLUMN individual.cd_life_stage IS 'Codigo del estadio de vida (ver tabla life_stage)';

CREATE TABLE deployment
(
    cd_deployment NUMBER(10,0) NOT NULL,
    cd_individual NUMBER(10,0) NOT NULL,
    cd_tracker NUMBER(10,0) NOT NULL,
    depl_start TIMESTAMP(2) NOT NULL,
    depl_end TIMESTAMP(2),
    movebank_deployment_id VARCHAR2(50) NOT NULL,
    CONSTRAINT deployment_pk PRIMARY KEY (cd_deployment),
    CONSTRAINT deployment_individual_fk FOREIGN KEY (cd_individual) REFERENCES individual(cd_individual),
    CONSTRAINT deployment_tracker_fk FOREIGN KEY (cd_tracker) REFERENCES tracker(cd_tracker),
    CONSTRAINT deployment_depl_end_ck CHECK (depl_end IS NULL OR depl_end > depl_start),
    CONSTRAINT deployment_deployment_id_un UNIQUE (movebank_deployment_id)
);

/* TRIGGER and SEQUENCE TO MAKE cd_deployment as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_deployment_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_deployment_seq_tr
    BEFORE INSERT ON deployment FOR EACH ROW
WHEN (NEW.cd_deployment IS NULL OR NEW.cd_deployment = 0)
BEGIN
    SELECT cd_deployment_seq.NEXTVAL INTO :NEW.cd_deployment FROM dual;
END;

COMMENT ON COLUMN deployment.cd_deployment IS 'Identificador del despliegue (autoincremental)';
COMMENT ON COLUMN deployment.cd_individual IS 'Identificador del individuo (ver tabla individual)';
COMMENT ON COLUMN deployment.cd_tracker IS 'Identificador del tracker (ver tabla tracker)';
COMMENT ON COLUMN deployment.depl_start IS 'Fecha y tiempo del despliegue (primer dato desde la instalación del tracker en el animal)';
COMMENT ON COLUMN deployment.depl_end IS 'Fecha y tiempo final del despliegue (puede ser nulo si el rastreo está en curso hasta una fecha desconocida)';
COMMENT ON COLUMN deployment.movebank_deployment_id IS 'Identificador del despliegue en movebank.org';


CREATE TABLE geo_log
(
    cd_log NUMBER(38,0) NOT NULL,
    cd_tracker NUMBER(38,0) NOT NULL, -- tracker? Individual? deployment? (by any of the 3 possibilty we should be able to get the other 2 using the date
    movebank_event_id VARCHAR2(20),
    date_time TIMESTAMP NOT NULL,
    elevation NUMBER,
    purged NUMBER(1,0) DEFAULT 0,
    temperature NUMBER,
    h_dop NUMBER,
    ground_speed NUMBER,
    heading NUMBER,
    voltage NUMBER,
    the_geom SDO_GEOMETRY,
    CONSTRAINT geo_log_pk PRIMARY KEY (cd_log),
    CONSTRAINT geo_log_tracker_fk FOREIGN KEY (cd_tracker) REFERENCES tracker (cd_tracker),
    CONSTRAINT elevation_ck CHECK (elevation > 0),
    CONSTRAINT heading_ck CHECK (heading >= 0 AND heading <= 360)
);

/* TRIGGER and SEQUENCE TO MAKE cd_log as an autoincremental variable (postgres equivalent: smallserial)*/
CREATE SEQUENCE cd_log_seq START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER cd_log_seq_tr
    BEFORE INSERT ON geo_log FOR EACH ROW
WHEN (NEW.cd_log IS NULL OR NEW.cd_log = 0)
BEGIN
    SELECT cd_log_seq.NEXTVAL INTO :NEW.cd_log FROM dual;
END;

COMMENT ON COLUMN geo_log.cd_log IS 'Identificador del registro espacial (autoincremental)';
COMMENT ON COLUMN geo_log.cd_tracker IS 'Identificador del tracker (ver tabla tracker)';
COMMENT ON COLUMN geo_log.date_time IS 'Fecha y tiempo asociados con la localización';
COMMENT ON COLUMN geo_log.elevation IS 'Altitud asociada con la localización (altitud medida, no del suelo)';
COMMENT ON COLUMN geo_log.purged IS 'Registro evaluado y marcado como error (manualmente, o por un filtro aplicado en movebank)';
COMMENT ON COLUMN geo_log.h_dop IS 'Dilución de la precision horizontal de la localización';
COMMENT ON COLUMN geo_log.temperature IS 'Temperatura';
COMMENT ON COLUMN geo_log.ground_speed IS 'Velocidad medida con accelerometro';
COMMENT ON COLUMN geo_log.heading IS 'Dirección de desplazamiento en grados';
COMMENT ON COLUMN geo_log.voltage IS 'Voltaje en el tracker';
COMMENT ON COLUMN geo_log.the_geom IS 'Datos de localización en el formato SDO_GEOMETRY de Oracle (punto de 2 dimensiones, SRID 4326, tolerancia subjetiva de 0.005 grados decimales)';

/* To make sure that geo_log are points, we will use the index-based mechanism...*/
/* We will need to insert the metadata for the SDO_GEOMETRY constraint in the  USER_SDO_GEOM_METADATA  (see p.50 of the book Pro Oracle spatial for Oracle database 11g)*/

