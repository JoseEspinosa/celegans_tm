#!/usr/bin/env nextflow

/*
 * Jose Espinosa-Carrasco. CB-CRG. June 2017
 *
 * Script to process time machine files from C. elegans recordings
*/

params.recordings = "$baseDir/data/2017_06_09=morphology_data=two_temperature_four_plates.csv"
params.mappings   = "$baseDir/data/tm2pergola.txt"

log.info "tm_to_Pergola - version 0.1"
log.info "============================================"
log.info "time machine recordings  : ${params.recordings}"
log.info "mappings                 : ${params.mappings}"
//log.info "output                   : ${params.output}"
log.info "\n"

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
// I don't have all the worms ids for this reason i only take the ones that have
// an id by the moment to create a first visualization
*/
//file worms_speed2p from map_speed
rec_worm = rec_file
    .splitCsv (header: true) { row ->
        [ row['Stationary Worm ID'], row.values().join(',') ] //, row.keySet().join(',')
    }
    .filter { row ->
        row[0] != "0"
    }
    .collectFile(newLine: true, seed: "ID_worm_nxf,Source Region ID,Capture Time,Position in Source Image X,Position in Source Image Y,Size in Source Image X,Size in Source Image Y,Identified as a worm by human,Identified as a worm by machine,Identified as an incorrectly thresholded worm,Identified as an incorrectly disambiguated multiple worm group,Identified as a small larvae,pixel_area,bitmap_width,bitmap_height,bitmap_diagonal,spine_length,distance_between_ends,width_average,width_max,width_min,width_variance,width_at_center,width_at_end_0,width_at_end_1,spine_length_to_area,spine_length_to_bitmap_width_ratio,spine_length_to_bitmap_height_ratio,spine_length_to_bitmap_diagonal_ratio,spine_length_to_max_width_ratio,spine_length_to_average_width,end_width_to_middle_width_ratio_0,end_width_to_middle_width_ratio_1,end_width_ratio,curvature_average,curvature_maximum,curvature_total,curvature_variance,curvature_x_intercepts,intensity_rel_average,intensity_rel_variance,intensity_rel_skew,intensity_rel_maximum,intensity_rel_spine_average,intensity_rel_spine_variance,intensity_rel_roughness_entropy,intensity_rel_roughness_spatial_var,intensity_rel_dark_avg,intensity_rel_dark_area,intensity_rel_neighborhood,intensity_rel_dist_from_neighborhood,intensity_rel_containing_image_average,intensity_rel_normalized_average,intensity_rel_normalized_max,intensity_rel_normalized_spine_average,intensity_abs_average,intensity_abs_variance,intensity_abs_skew,intensity_abs_maximum,intensity_abs_spine_average,intensity_abs_spine_variance,intensity_abs_roughness_entropy,intensity_abs_roughness_spatial_var,intensity_abs_dark_avg,intensity_abs_dark_area,intensity_abs_neighborhood,intensity_abs_dist_from_neighborhood,intensity_abs_containing_image_average,intensity_abs_normalized_average,intensity_abs_normalized_max,intensity_abs_normalized_spine_average,edge_area,edge_object_area_ratio,intensity_profile_edge,intensity_profile_center,intensity_profile_max,intensity_profile_variance,Experiment Name,Plate Name,Device,Strain,Condition 1,Condition 2,Condition 3,Culturing Temperature,Experiment Temperature,Food Source,Environmental Conditions,time spent included,time_spent_excluded,average_time,excluded by visual inspection,overlap with path match,Age (days),Stationary Worm ID,Movement State") { item->
	[ "id_worm${item[0]}.csv", item.join(",") ]
    }
    //.println()

process records_to_pergola {
    input:
    file (file_worm) from rec_worm
    file mapping_file

  	output:
  	//set '*_speed.csv', name_file_worm into speed_files, speed_files_wr
    stdout test_ch

  	script:

  	"""
  	pergola -i $file_worm -m $mapping_file -fs , -n
  	"""
}