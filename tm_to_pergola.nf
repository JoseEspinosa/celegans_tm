#!/usr/bin/env nextflow

/*
 * Jose Espinosa-Carrasco. CB-CRG. June 2017
 *
 * Script to process time machine files from C. elegans recordings
*/

params.recordings = "$baseDir/data/2017_06_09=morphology_data=two_temperature_four_plates.csv"
params.mappings   = "$baseDir/data/tm2pergola.txt"
params.output     = "results/"

log.info "tm_to_Pergola - version 0.1"
log.info "============================================"
log.info "time machine recordings  : ${params.recordings}"
log.info "mappings                 : ${params.mappings}"
log.info "output                   : ${params.output}"
log.info "\n"

/*
nextflow run tm_to_pergola.nf --recordings 'data/small_track.csv' \
        --mappings 'data/tm2pergola.txt' \
	    -with-docker -resumeola.txt' \
	    -with-docker -resume
*/

/*
 * Input files validation
 */
Channel
    .fromPath( params.recordings )
    .ifEmpty { error "Missing recordings file" }
    .set { rec_file }

mapping_file = file(params.mappings)
if( !mapping_file.exists() ) exit 1, "Missing mapping file: ${mapping_file}"

/*
 * Create a channel for strain 2 worm trackings
*/
// Worms with ID are in the stationary phase, before they can not be individually tracked
// First approach visualize this guys
rec_file.into { rec_file_1; rec_file_2; rec_file_min_max }

/*
 * Getting min and time capture in file
 */
process min_max_capture_time {
    input:
    file (file_worm) from rec_file_min_max

    output:
    stdout into min_max_t

    exec:
    println "File processed $file_worm"

    script:

    """
    min_max_capture_t=`awk -F , 'NR == 2 {min = \$2; max = \$2}
    NR > 2 && \$2 < min {min = \$2}
    NR > 2 && \$2 > max {max = \$2}
    END{print min","max}' ${file_worm}`

    printf "\$min_max_capture_t"
    """
}

min_max_t.into { min_max_time; min_max_time_b; min_max_time_bg }
min_max_time.println()

/*
 * Worms culture at 27 degrees
*/
rec_worm_27 = rec_file_1
    .splitCsv (header: true) { row ->
        [ row['Stationary Worm ID'], row.values().join(',') ] //, row.keySet().join(',')
    }
    .filter { row ->
        row[0] != "0"
    }
    .filter { row ->
        row[1].split(",")[84] == "27"
    }
    .collectFile(newLine: true, seed: "ID_worm_nxf,Source Region ID,Capture Time,Position in Source Image X,Position in Source Image Y,Size in Source Image X,Size in Source Image Y,Identified as a worm by human,Identified as a worm by machine,Identified as an incorrectly thresholded worm,Identified as an incorrectly disambiguated multiple worm group,Identified as a small larvae,pixel_area,bitmap_width,bitmap_height,bitmap_diagonal,spine_length,distance_between_ends,width_average,width_max,width_min,width_variance,width_at_center,width_at_end_0,width_at_end_1,spine_length_to_area,spine_length_to_bitmap_width_ratio,spine_length_to_bitmap_height_ratio,spine_length_to_bitmap_diagonal_ratio,spine_length_to_max_width_ratio,spine_length_to_average_width,end_width_to_middle_width_ratio_0,end_width_to_middle_width_ratio_1,end_width_ratio,curvature_average,curvature_maximum,curvature_total,curvature_variance,curvature_x_intercepts,intensity_rel_average,intensity_rel_variance,intensity_rel_skew,intensity_rel_maximum,intensity_rel_spine_average,intensity_rel_spine_variance,intensity_rel_roughness_entropy,intensity_rel_roughness_spatial_var,intensity_rel_dark_avg,intensity_rel_dark_area,intensity_rel_neighborhood,intensity_rel_dist_from_neighborhood,intensity_rel_containing_image_average,intensity_rel_normalized_average,intensity_rel_normalized_max,intensity_rel_normalized_spine_average,intensity_abs_average,intensity_abs_variance,intensity_abs_skew,intensity_abs_maximum,intensity_abs_spine_average,intensity_abs_spine_variance,intensity_abs_roughness_entropy,intensity_abs_roughness_spatial_var,intensity_abs_dark_avg,intensity_abs_dark_area,intensity_abs_neighborhood,intensity_abs_dist_from_neighborhood,intensity_abs_containing_image_average,intensity_abs_normalized_average,intensity_abs_normalized_max,intensity_abs_normalized_spine_average,edge_area,edge_object_area_ratio,intensity_profile_edge,intensity_profile_center,intensity_profile_max,intensity_profile_variance,Experiment Name,Plate Name,Device,Strain,Condition 1,Condition 2,Condition 3,Culturing Temperature,Experiment Temperature,Food Source,Environmental Conditions,time spent included,time_spent_excluded,average_time,excluded by visual inspection,overlap with path match,Age (days),Stationary Worm ID,Movement State") { item->
	[ "id_worm${item[0]}.csv", item.join(",") ]
    }
    .map { [ it, "high_T" ]}
    //.println()

/*
 * Worms culture at 20 degrees
*/
rec_worm_20 = rec_file_2
    .splitCsv (header: true) { row ->
        [ row['Stationary Worm ID'], row.values().join(',') ] //, row.keySet().join(',')
    }
    .filter { row ->
        row[0] != "0"
        row[0] = 100 + row[0].toInteger()
    }
    .filter { row ->
        row[1].split(",")[84] == "20"
    }
    .collectFile(newLine: true, seed: "ID_worm_nxf,Source Region ID,Capture Time,Position in Source Image X,Position in Source Image Y,Size in Source Image X,Size in Source Image Y,Identified as a worm by human,Identified as a worm by machine,Identified as an incorrectly thresholded worm,Identified as an incorrectly disambiguated multiple worm group,Identified as a small larvae,pixel_area,bitmap_width,bitmap_height,bitmap_diagonal,spine_length,distance_between_ends,width_average,width_max,width_min,width_variance,width_at_center,width_at_end_0,width_at_end_1,spine_length_to_area,spine_length_to_bitmap_width_ratio,spine_length_to_bitmap_height_ratio,spine_length_to_bitmap_diagonal_ratio,spine_length_to_max_width_ratio,spine_length_to_average_width,end_width_to_middle_width_ratio_0,end_width_to_middle_width_ratio_1,end_width_ratio,curvature_average,curvature_maximum,curvature_total,curvature_variance,curvature_x_intercepts,intensity_rel_average,intensity_rel_variance,intensity_rel_skew,intensity_rel_maximum,intensity_rel_spine_average,intensity_rel_spine_variance,intensity_rel_roughness_entropy,intensity_rel_roughness_spatial_var,intensity_rel_dark_avg,intensity_rel_dark_area,intensity_rel_neighborhood,intensity_rel_dist_from_neighborhood,intensity_rel_containing_image_average,intensity_rel_normalized_average,intensity_rel_normalized_max,intensity_rel_normalized_spine_average,intensity_abs_average,intensity_abs_variance,intensity_abs_skew,intensity_abs_maximum,intensity_abs_spine_average,intensity_abs_spine_variance,intensity_abs_roughness_entropy,intensity_abs_roughness_spatial_var,intensity_abs_dark_avg,intensity_abs_dark_area,intensity_abs_neighborhood,intensity_abs_dist_from_neighborhood,intensity_abs_containing_image_average,intensity_abs_normalized_average,intensity_abs_normalized_max,intensity_abs_normalized_spine_average,edge_area,edge_object_area_ratio,intensity_profile_edge,intensity_profile_center,intensity_profile_max,intensity_profile_variance,Experiment Name,Plate Name,Device,Strain,Condition 1,Condition 2,Condition 3,Culturing Temperature,Experiment Temperature,Food Source,Environmental Conditions,time spent included,time_spent_excluded,average_time,excluded by visual inspection,overlap with path match,Age (days),Stationary Worm ID,Movement State") { item->
	    [ "id_worm${item[0]}.csv", item.join(",") ]
    }
    .map { [ it, "low_T" ]}
    //.println()

rec_worm_filter = rec_worm_20.mix ( rec_worm_27 )

rec_worm_filter.into { rec_worm_bed; rec_worm_bedGr }

//rec_worm_bed.println()

/*
 * Formatting the variable desired to bed file
 */

process records_to_pergola_bed {
    input:
    set file (file_worm), val (temp) from rec_worm_bed
    file mapping_file

    output:
    set file ('tr_*.bed'), val (temp) into bed_recordings

    script:

    """
    # -e because time is used to establish the age of the worm
    pergola -i ${file_worm} -m ${mapping_file} -fs , -n -e -nt
    #printf "\$min_capture_t"
    """
}

/*
 * Formatting the variable desired to bedGraph file
 */

process records_to_pergola_bedGraph {
    input:
    set file (file_worm), val (temp) from rec_worm_bedGr
    file mapping_file
    val min_max_t from min_max_time_b.first()

  	output:
  	set file ('tr_*.bedGraph'), val (temp) into bedGr_recordings
  	//set file ('file_worm'), val (name_file_worm), val (exp_group) from mat_file
    //stdout test_ch

  	script:

  	"""
  	min=\$(echo ${min_max_t} | cut -f1 -d ',')
  	max=\$(echo ${min_max_t} | cut -f2 -d ',')
  	awk -F , '!seen[\$3]++' $file_worm > ${file_worm}".mod"
 	# -e because time is used to establish the age of the worm
  	pergola -i ${file_worm}".mod" -m $mapping_file -f bedGraph -w 86400 -fs , -n -e -min \${min} -max \$max -nt
  	# pergola -i ${file_worm}".mod" -m $mapping_file -f bedGraph -fs , -n -e
  	"""
}

// me esta metiendo el 20 en el archivo!!!!
/*
 * Generating a file with the groups assignments for Pergola shiny
 */

f = new File('mappings_shiny_pergola.txt')
def w = f.newWriter()
f.append("sample" + "\t" + "condition" + "\n")

bedGr_recordings
    .map {
        def file = it[0]
        def group = it[1]
        //f.append(file.name.split("\\.")[0] + "\t" + group + "\n")
        f << file.name.split("\\.")[0] + "\t" + group + "\n"
    }


//subscribe().getClass()
//bedGr_recordings.split("\\.")[1].println()
//def pheno_feature =  it.name.split("\\.")[1]
