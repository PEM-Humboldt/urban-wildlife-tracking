INSERT INTO supplier(SUPPLIER,supplier_short)
SELECT * FROM TMP_SUPPLIER ;


INSERT INTO model(cd_supplier,model,model_short)
SELECT cd_supplier, model,  tm.model_short
FROM tmp_model tm
LEFT JOIN supplier s ON tm.supplier_short=s.supplier_short ;

INSERT INTO TRACKER (supplier_id,serial,movebank_tag,cd_model)
SELECT supplier_id,serial,movebank_tag,m.cd_model
FROM tmp_tracker tt
LEFT JOIN model m ON tt.model=m.model_short
ORDER BY supplier_id,serial,movebank_tag,cd_model;

INSERT INTO LIFE_STAGE 
SELECT * FROM TMP_LIFE_STAGE ;

INSERT INTO taxon(scientific_name,kingdom,phylum,"CLASS","ORDER",family,genus,specific_epithet,itis_tsn)
SELECT scientific_name,kingdom,phylum,"CLASS","ORDER",family,genus,specific_epithet,tsn
FROM tmp_taxon;

INSERT INTO individual(nick_name,movebank_animal_id,cd_taxon,sex,cd_life_stage)
SELECT nick_name,movebank_animal_id,cd_taxon,
	CASE 
		WHEN sex='f' THEN 'female'
		WHEN sex='m' THEN 'male'
		WHEN sex IS NULL OR sex='' THEN NULL
		ELSE 'unknown'
	END,
cd_life_stage
FROM tmp_individual ti
LEFT JOIN taxon t ON ti.canonical_name=t.scientific_name
LEFT JOIN life_stage ls ON ti.life_stage=ls.life_stage;

INSERT INTO deployment(cd_individual,cd_tracker,depl_start,movebank_deployment_id)
SELECT cd_individual,cd_tracker,TO_TIMESTAMP( date_time_start,'yyyy-MM-dd HH24:mi:ss.FF'),movebank_deployment_id
FROM TMP_DEPLOYMENT td
LEFT JOIN INDIVIDUAL i USING(nick_name)
LEFT JOIN tracker t ON td.movebank_tag_id=t.movebank_tag;

INSERT INTO geo_log(cd_tracker,movebank_event_id,date_time,elevation,purged,h_dop,ground_speed,heading,voltage,the_geom)
SELECT cd_tracker,
	event_id,
	TO_TIMESTAMP("TIMESTAMP",'yyyy-MM-dd HH24:mi:ss'),
	CASE 
		WHEN height_above_msl<=0 THEN NULL
		ELSE height_above_msl
	END
	,
	purged,
	gps_hdop,
	ground_speed,
	heading,
	tag_voltage,
	SDO_GEOMETRY(2001,4326,sdo_point_type(location_long,location_lat,NULL),NULL ,NULL)
FROM tmp_geo_log tgl
LEFT JOIN tracker t ON tgl.tag_id=t.movebank_tag;
	
DROP TABLE TMP_DEPLOYMENT ;
DROP TABLE TMP_GEO_LOG ;
DROP TABLE TMP_INDIVIDUAL;
DROP TABLE TMP_LIFE_STAGE ;
DROP TABLE TMP_SUPPLIER ;
DROP TABLE TMP_MODEL ;
DROP TABLE TMP_TAXON ;
DROP TABLE TMP_TRACKER ;
