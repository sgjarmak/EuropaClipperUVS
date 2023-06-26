;+
; NAME:
;   planning_obs_europa_clipper
; PURPOSE:
;   Given an time range and a set of metakernels, 
;   generate an estimated data count
; DESCRIPTION:
; CATEGORY:
; CALLING SEQUENCE:
; INPUTS:
; OPTIONAL INPUT PARAMETERS:
; KEYWORD INPUT PARAMETERS:
; OUTPUTS:
; KEYWORD OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;  04/26/2022 - Written by Remote Sensing Group, SwRI
;  05/16/2023 - Modifications to run on Jarmak computer
;  
;-
pro planning_obs_europa_clipper_v3sj, path, t0, t1, n_exposure, spacecraft, meta_kernel, moon

  t0 = '07/16/2033 12:00:00'
  t1 = '07/16/2033 13:00:00'
  
  n_exposure = 3
  spacecraft = 'Europa'
  moon = 'Europa'

;Plotting parameter
csz = 1.6
symb = 2
plot_win = 1

;SETENV, "PATH=/opt/local/bin:/opt/local/sbin:/opt/local/bin:/opt/local/sbin:/sw/bin:/sw/sbin:"+$
;  "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/Library/TeX/texbin:"+$
;  "/Applications/nedit-5.5:/Users/vincent/CSPICE/icy/exe"



meta_kernel = '/Users/sjarmak/EuropaClipper/SPICE/metakernels/'

;;meta_kernel =  '/Users/vhue/Kernels_SPICE/Europa_Clipper/metakernels/metakernel_test.ker'
;list_kernel = '/Users/vhue/Desktop/Projects/Europa_Clipper/metakernel/21F31_V4_CK-Bundle_v21-10/21F31_V4_Tour_kernels.mk'
;if file_test(meta_kernel) eq 0 then build_metakernel_from_list, list_kernel, meta_kernel

;cspice_kclear
;cspice_furnsh, meta_kernel

; =============================================



; @@@@@@@@@@@@@@@@@ SPICE SET UP @@@@@@@@@@@@@@@@@

path = '/Users/sjarmak/EuropaClipper/VincentCode/Planning_Public/'
moon = 'Europa'


spacecraft = 'Europa'
tour = '21F31_v4'

cspice_kclear

; ============= Directories ==================

filedir      = '/Users/sjarmak/EuropaClipper/MissionTrajectories/Tour_Outputs/'
opsdir       = '/Users/sjarmak/EuropaClipper/MissionTrajectories/Tour_Activities/'
kerndir      = '/Users/sjarmak/EuropaClipper/MissionTrajectories/Tour_Kernels/'
pathdir      = '/Users/sjarmak/EuropaClipper/SPICE/'
savedir      = '/Users/sjarmak/EuropaClipper/ActivityDefinitions/europa_uvs_tour_observations_results/'
raddir       = '/Users/sjarmak/EuropaClipper/Science_Planning_Webtool/RandyCode/'
timelinedir  = '/Users/sjarmak/EuropaClipper/Science_Planning_Webtool/FlybyTool_Timelines/'
outputdir    = '/Users/sjarmak/EuropaClipper/ActivityDefinitions/GeometryOutputs/'

if tour eq '21F31_v4' then begin
  encounterfile = filedir + '21F31_MEGA_L241010_A300411_LP01_V4_OUTPUT/' + '21F31_MEGA_L241010_A300411_LP01_V4_DETAILED_ENCOUNTERS.csv'
  timelinesav = 'Webtool_timeline_21F31_v4'
  kernfile  = kerndir + '21F31_v4/21F31_MEGA_L241010_A300411_LP01_V4_scpse.bsp'
  ckernfile = kerndir + '21F31_v4/clipper_sc_21F31_V4_Tour_Simulation.bc'
  ckernfile2 = kerndir + '21F31_v4/clipper_sa_21F31_V4_Tour_Simulation.bc'
endif

radfile = 'electron_dose_europa_15F10_DIR_L220614_A250305_V1_scpse_ten_min_10112015.sav' ;don't have this, is this to be generated?
file_wavelength_solution = '/Users/sjarmak/EuropaClipper/Effective_area/Wavelength_solution/wavelength_solution_europa.sav'

; =============================================



; @@@@@@@@@@@@@@@@@ SPICE SET UP @@@@@@@@@@@@@@@@@

;cspice_furnsh, pathdir + 'lsk/naif0012.tls'
;cspice_furnsh, pathdir + 'pck/pck00010.tpc'
;cspice_furnsh, pathdir + 'spk/de432s.bsp' 
;cspice_furnsh, pathdir + 'spk/jup310.bsp'
;cspice_furnsh, pathdir + 'fk/clipper_v16.tf'
;cspice_furnsh, pathdir + 'tkernels/clipper_uvs_v07.ti'
;cspice_furnsh, pathdir + 'SCLK/EUROPA_SCLKSCET.00001.tsc'
;cspice_furnsh, kerndir + '21F31_v4/europaclipper_00000.tsc'        
;
;cspice_furnsh, kernfile
;cspice_furnsh, ckernfile
;cspice_furnsh, ckernfile2

kernfile = '/Users/sjarmak/EuropaClipper/SPICE/VincentCode_Kernels.txt'
cspice_furnsh, kernfile



path_output=path+'Output/'
if file_test(path_output) eq 0 then spawn, 'mkdir '+path_output
spawn, 'rm '+path_output+'*'

path_geometry = path+'Output/Geometry/'
if file_test(path_geometry) eq 0 then spawn, 'mkdir '+path_geometry


cspice_str2et, t0, t0_et
cspice_str2et, t1, t1_et

; number of histograms within t0-t1
time_array_et = fill_array(t0_et, t1_et, n_exposure)
x = 1.7
time_array_et = t0_et +  (fill_array(0.^(1/x), (t1_et-t0_et)^(1/x), n_exposure))^x
cspice_et2utc, time_array_et, 'ISOC', 0, time_array_utc


label_time = strmid(time_array_utc[0],0,4)+strmid(time_array_utc[0],5,2)+strmid(time_array_utc[0],8,2)+'T'+strmid(time_array_utc[0],11,2)+strmid(time_array_utc[0],14,2)+strmid(time_array_utc[0],17,2)+'_'+$
             strmid(time_array_utc[-1],0,4)+strmid(time_array_utc[-1],5,2)+strmid(time_array_utc[-1],8,2)+'T'+strmid(time_array_utc[-1],11,2)+strmid(time_array_utc[-1],14,2)+strmid(time_array_utc[-1],17,2)+'_nt_'+string(n_exposure,f='(i04)')



filename_geometry = path_geometry+Spacecraft+'_'+label_time+'.sav'
;spawn, 'rm '+filename_geometry
if file_test(filename_geometry) eq 0 then compute_geometry_element, path_geometry, time_array_et, time_array_utc, spacecraft, filename_geometry  
restore, filename_geometry, /verbose

;stop

load_solar_spectrum, wvl, irrad

; Restore the wavelength solution

file_wavelength_solution = '/Users/sjarmak/EuropaClipper/Effective_area/Wavelength_solution/wavelength_solution_europa.sav'
restore, file_wavelength_solution, /verbose
;xpix = 
;ypix = 

; Restore the effective area
file_eff_area = '/Users/sjarmak/EuropaClipper/Effective_area/Output/Europa_UVS_EffArea_20220331.sav'
restore, file_eff_area, /verbose
w_ea = w
ea_AP = EFFAREA_AP
ea_SP = EFFAREA_SP


;moon = 'Ganymede'
;moon = 'Europa'

case 1 of
  moon eq 'Europa': begin
    lat_pixel_AP = lat_pixel_AP_europa & lon_pixel_AP = lon_pixel_AP_europa
    pixel_incidence_angle_AP = pixel_incidence_angle_AP_europa & pixel_emission_angle_AP = pixel_emission_angle_AP_europa
    pixel_phase_angle_AP = pixel_phase_angle_AP_europa & dist_pixel_AP = dist_pixel_AP_europa
    lat_pixel_SP = lat_pixel_SP_europa & lon_pixel_SP = lon_pixel_SP_europa
    pixel_incidence_angle_SP = pixel_incidence_angle_SP_europa & pixel_emission_angle_SP = pixel_emission_angle_SP_europa
    pixel_phase_angle_SP = pixel_phase_angle_SP_europa & dist_pixel_SP = dist_pixel_SP_europa
  end
  moon eq 'Io': begin
    lat_pixel_AP = lat_pixel_AP_io & lon_pixel_AP = lon_pixel_AP_io
    pixel_incidence_angle_AP = pixel_incidence_angle_AP_io & pixel_emission_angle_AP = pixel_emission_angle_AP_io
    pixel_phase_angle_AP = pixel_phase_angle_AP_io & dist_pixel_AP = dist_pixel_AP_io
    lat_pixel_SP = lat_pixel_SP_io & lon_pixel_SP = lon_pixel_SP_io
    pixel_incidence_angle_SP = pixel_incidence_angle_SP_io & pixel_emission_angle_SP = pixel_emission_angle_SP_io
    pixel_phase_angle_SP = pixel_phase_angle_SP_io & dist_pixel_SP = dist_pixel_SP_io
  end
  moon eq 'Ganymede': begin
    lat_pixel_AP = lat_pixel_AP_ganymede & lon_pixel_AP = lon_pixel_AP_ganymede
    pixel_incidence_angle_AP = pixel_incidence_angle_AP_ganymede & pixel_emission_angle_AP = pixel_emission_angle_AP_ganymede
    pixel_phase_angle_AP = pixel_phase_angle_AP_ganymede & dist_pixel_AP = dist_pixel_AP_ganymede
    lat_pixel_SP = lat_pixel_SP_ganymede & lon_pixel_SP = lon_pixel_SP_ganymede
    pixel_incidence_angle_SP = pixel_incidence_angle_SP_ganymede & pixel_emission_angle_SP = pixel_emission_angle_SP_ganymede
    pixel_phase_angle_SP = pixel_phase_angle_SP_ganymede & dist_pixel_SP = dist_pixel_SP_ganymede
  end
  moon eq 'Callisto': begin
    lat_pixel_AP = lat_pixel_AP_callisto & lon_pixel_AP = lon_pixel_AP_callisto
    pixel_incidence_angle_AP = pixel_incidence_angle_AP_callisto & pixel_emission_angle_AP = pixel_emission_angle_AP_callisto
    pixel_phase_angle_AP = pixel_phase_angle_AP_callisto & dist_pixel_AP = dist_pixel_AP_callisto
    lat_pixel_SP = lat_pixel_SP_callisto & lon_pixel_SP = lon_pixel_SP_callisto
    pixel_incidence_angle_SP = pixel_incidence_angle_SP_callisto & pixel_emission_angle_SP = pixel_emission_angle_SP_callisto
    pixel_phase_angle_SP = pixel_phase_angle_SP_callisto & dist_pixel_SP = dist_pixel_SP_callisto
  end
endcase


radiation_detector, spacecraft, spacecraft_id, time_array_et, time_array_utc, n_pix_y, moon, w_ea, ea_AP, ea_SP, wvl, irrad, $
                    rho_dip_sc_RJ, z_dip_sc_RJ, detector_counts_radiation

add_counting_noise, detector_counts_radiation, detector_counts_radiation_noise


file_refl = path_output+'refl.sav'

spawn, 'rm '+file_refl
if file_test(file_refl) eq 0 then begin
surface_reflectance_moon, spacecraft, spacecraft_id, time_array_et, time_array_utc, moon, w_ea, ea_AP, ea_SP, sr_per_pix, wvl, irrad, $
                         lat_pixel_AP, lon_pixel_AP, pixel_incidence_angle_AP, pixel_emission_angle_AP, pixel_phase_angle_AP, dist_pixel_AP, $
                         lat_pixel_SP, lon_pixel_SP, pixel_incidence_angle_SP, pixel_emission_angle_SP, pixel_phase_angle_SP, dist_pixel_SP, $
                         detector_counts_AP, detector_counts_SP

save, filename=file_refl, lat_pixel_AP, lon_pixel_AP, detector_counts_AP
endif else begin
  restore, file_refl, /verbose
endelse

add_counting_noise, detector_counts_AP, detector_counts_AP_noise

detector_counts_tot = detector_counts_AP + detector_counts_radiation_noise/15.
save_detector_image, path_output, spacecraft, time_array_utc, wvl, detector_counts_tot

print, 'LAT PIXEL AP EUROPA'
print, n_elements(lat_pixel_AP_europa[*,0])
print, 'LAT PIXEL AP'
print, n_elements(lat_pixel_AP[*,0])
 
plotpath = path+'Plots/'+label_time+'/'
make_visual_v2, plotpath, 'Refl_Rad', spacecraft, spacecraft_id, time_array_et, time_array_utc, moon, lat_pixel_AP, lon_pixel_AP, detector_counts_AP+detector_counts_radiation_noise, wvl
stop
make_visual_v2, plotpath, 'Radiation', spacecraft, spacecraft_id, time_array_et, time_array_utc, moon, lat_pixel_AP, lon_pixel_AP, detector_counts_radiation_noise, wvl
stop
make_visual_v2, plotpath, 'Reflected', spacecraft, spacecraft_id, time_array_et, time_array_utc, moon, lat_pixel_AP, lon_pixel_AP, detector_counts_AP, wvl
stop





 if plot_win then begin
   restore, '/Users/sjarmak/EuropaClipper/Maps/Europa/Europa.sav', /verbose

   min_phase_ang = min(pixel_phase_angle_AP[where(pixel_phase_angle_AP ne -999., /null)])
   max_phase_ang = max(pixel_phase_angle_AP[where(pixel_phase_angle_AP ne -999., /null)])
   phase_angle_array = fill_array(min_phase_ang, max_phase_ang, 255)

   window,0, xs=1500, ys=900
   device, decomposed=1
   loadct, 0

   min_lat = -15.
   min_lat = -90.
   max_lat = 10.
   max_lat = 90.
   ind = where(LAT_ARRAY ge min_lat and LAT_ARRAY le max_lat, /null)
   cgimage, MAP_LONLAT[*,*,ind], xvector=W_LON_ARRAY, yvector=LAT_ARRAY[ind], xr=[W_LON_ARRAY[0],W_LON_ARRAY[-1]], yr=[min(LAT_ARRAY[ind]),max(LAT_ARRAY[ind])], /axes, xt='Longitude', yt='Latitude', position=[0.05, 0.07, 0.99, 0.90]
   loadct, 33
   TVLCT, R, G, B, /GET

   for i = 0,n_elements(time_array_et) -1 do begin
     for j = 0,n_elements(lon_pixel_AP[*,0])-1, 1 do begin
       ic = value_locate(phase_angle_array, pixel_phase_angle_AP[j,i])
       cgoplot, lon_pixel_AP[j,i], lat_pixel_AP[j,i], psym=symb, symsize=0.6, color = cgColor24( [r[ic],g[ic],b[ic]])
     endfor
     cgoplot, subsolar_europa_lon[i], subsolar_europa_lat[i], psym=symb, symsize=0.7, color=cgcolor('orange')
     cgoplot, subsc_europa_lon[i], subsc_europa_lat[i], psym=7, symsize=2, thick=2, color=cgcolor('black')
   endfor

   cgoplot, subsc_europa_lon[0], subsc_europa_lat[0], psym=7, symsize=2, thick=2, color=cgcolor('blue')
   cgoplot, subsc_europa_lon[-1], subsc_europa_lat[-1], psym=7, symsize=2, thick=2, color=cgcolor('red')

   cgoplot, subsolar_europa_lon[0], subsolar_europa_lat[0], psym=symb, symsize=0.7, color=cgcolor('blue')
   cgoplot, subsolar_europa_lon[-1], subsolar_europa_lat[-1], psym=symb, symsize=0.7, color=cgcolor('red')

   cgcolorbar, minrange=min_phase_ang, maxrange=max_phase_ang, position=[0.1, 0.97, 0.90, 0.999], TITLE='Phase Angle', charsize=csz-0.2, minor=10


   ;##############################################################################################
   ;##############################################################################################
   min_incidence = min(pixel_incidence_angle_AP[where(pixel_incidence_angle_AP ne -999., /null)])
   max_incidence = max(pixel_incidence_angle_AP[where(pixel_incidence_angle_AP ne -999., /null)])
   inc_angle_array = fill_array(min_incidence, max_incidence, 255)

   window,1, xs=1500, ys=900
   device, decomposed=1
   loadct, 0

   min_lat = -15.
   min_lat = -90.
   max_lat = 10.
   max_lat = 90.
   ind = where(LAT_ARRAY ge min_lat and LAT_ARRAY le max_lat, /null)
   cgimage, MAP_LONLAT[*,*,ind], xvector=W_LON_ARRAY, yvector=LAT_ARRAY[ind], xr=[W_LON_ARRAY[0],W_LON_ARRAY[-1]], yr=[min(LAT_ARRAY[ind]),max(LAT_ARRAY[ind])], /axes, xt='Longitude', yt='Latitude', position=[0.05, 0.07, 0.99, 0.90]
   loadct, 33
   TVLCT, R, G, B, /GET

   for i = 0,n_elements(time_array_et) -1 do begin
     for j = 0,n_elements(lon_pixel_AP[*,0])-1, 1 do begin
       ic = value_locate(inc_angle_array, pixel_incidence_angle_AP[j,i])
       cgoplot, lon_pixel_AP[j,i], lat_pixel_AP[j,i], psym=symb, symsize=0.6, color = cgColor24( [r[ic],g[ic],b[ic]])
     endfor
     ;cgoplot, lon_pixel_AP[0:-1:50,i], lat_pixel_AP[0:-1:10,i], psym=symb, symsize=0.4
     cgoplot, subsolar_europa_lon[i], subsolar_europa_lat[i], psym=symb, symsize=0.7, color=cgcolor('orange')
     cgoplot, subsc_europa_lon[i], subsc_europa_lat[i], psym=7, symsize=2, thick=2, color=cgcolor('black')

   endfor

   cgoplot, subsc_europa_lon[0], subsc_europa_lat[0], psym=7, symsize=2, thick=2, color=cgcolor('blue')
   cgoplot, subsc_europa_lon[-1], subsc_europa_lat[-1], psym=7, symsize=2, thick=2, color=cgcolor('red')

   cgoplot, subsolar_europa_lon[0], subsolar_europa_lat[0], psym=symb, symsize=0.7, color=cgcolor('blue')
   cgoplot, subsolar_europa_lon[-1], subsolar_europa_lat[-1], psym=symb, symsize=0.7, color=cgcolor('red')

   cgcolorbar, minrange=min_incidence, maxrange=max_incidence, position=[0.1, 0.97, 0.90, 0.999], TITLE='Incidence Angle', charsize=csz-0.2, minor=10


   ;##############################################################################################
   ;##############################################################################################
   min_em_angle = min(pixel_emission_angle_AP[where(pixel_emission_angle_AP ne -999., /null)])
   max_em_angle = max(pixel_emission_angle_AP[where(pixel_emission_angle_AP ne -999., /null)])
   em_angle_array = fill_array(min_em_angle, max_em_angle, 255)

   window,2, xs=1500, ys=900
   device, decomposed=1
   loadct, 0

   min_lat = -15.
   min_lat = -90.
   max_lat = 10.
   max_lat = 90.
   ;ind = where(LAT_ARRAY ge min_lat and LAT_ARRAY le max_lat, /null)
   ;cgimage, MAP_LONLAT, xvector=W_LON_ARRAY, yvector=LAT_ARRAY, xr=[W_LON_ARRAY[0],W_LON_ARRAY[-1]], /axes, xt='Longitude', yt='Latitude', position=[0.05, 0.07, 0.99, 0.90]
   ind = where(LAT_ARRAY ge min_lat and LAT_ARRAY le max_lat, /null)
   cgimage, MAP_LONLAT[*,*,ind], xvector=W_LON_ARRAY, yvector=LAT_ARRAY[ind], xr=[W_LON_ARRAY[0],W_LON_ARRAY[-1]], yr=[min(LAT_ARRAY[ind]),max(LAT_ARRAY[ind])], /axes, xt='Longitude', yt='Latitude', position=[0.05, 0.07, 0.99, 0.90]
   loadct, 33
   TVLCT, R, G, B, /GET

   for i = 0,n_elements(time_array_et) -1 do begin
     for j = 0,n_elements(lon_pixel_AP[*,0])-1, 1 do begin
       ic = value_locate(em_angle_array, pixel_emission_angle_AP[j,i])
       cgoplot, lon_pixel_AP[j,i], lat_pixel_AP[j,i], psym=symb, symsize=0.6, color = cgColor24( [r[ic],g[ic],b[ic]])
     endfor
     cgoplot, subsolar_europa_lon[i], subsolar_europa_lat[i], psym=symb, symsize=0.7, color=cgcolor('orange')
     cgoplot, subsc_europa_lon[i], subsc_europa_lat[i], psym=7, symsize=2, thick=2, color=cgcolor('black')
   endfor
   cgoplot, subsc_europa_lon[0], subsc_europa_lat[0], psym=7, symsize=2, thick=2, color=cgcolor('blue')
   cgoplot, subsc_europa_lon[-1], subsc_europa_lat[-1], psym=7, symsize=2, thick=2, color=cgcolor('red')

   cgoplot, subsolar_europa_lon[0], subsolar_europa_lat[0], psym=symb, symsize=0.7, color=cgcolor('blue')
   cgoplot, subsolar_europa_lon[-1], subsolar_europa_lat[-1], psym=symb, symsize=0.7, color=cgcolor('red')

   cgcolorbar, minrange=min_em_angle, maxrange=max_em_angle, position=[0.1, 0.97, 0.90, 0.999], TITLE='Emission Angle', charsize=csz-0.2, minor=10

   window,2, xs=1500, ys=900
   cgplot, time_array_hr_since_start, size_jupiter, yrange=[4d-2,max([size_jupiter, size_Io, size_Europa, size_ganymede, size_callisto])], /ylog, xt='time [hr past '+time_array_utc[0]+']', yt='angular sizes [deg]', xs=1, charsize=csz
   cgoplot, time_array_hr_since_start, size_Io, color=cgcolor('red')
   cgoplot, time_array_hr_since_start, size_Europa, color=cgcolor('blue')
   cgoplot, time_array_hr_since_start, size_ganymede, color=cgcolor('green')
   cgoplot, time_array_hr_since_start, size_callisto, color=cgcolor('purple')
   cgtext,0.15,0.88,'Jupiter', /normal, charsize=csz
   cgtext,0.15,0.84,'Io', /normal, color=cgcolor('red'), charsize=csz
   cgtext,0.15,0.80,'Europa', /normal, color=cgcolor('blue'), charsize=csz
   cgtext,0.15,0.76,'Ganymede', /normal, color=cgcolor('green'), charsize=csz
   cgtext,0.15,0.72,'Callisto', /normal, color=cgcolor('purple'), charsize=csz


   window,3,xs=800,ys=500
   cgplot, time_array_hr_since_start, sc_range_jupiter, yrange=[4d-2,max([sc_range_jupiter, altitude_sc_europa, altitude_sc_io, altitude_sc_ganymede, altitude_sc_callisto])], /ylog,  xt='time [hr past '+time_array_utc[0]+']', yt='Distance [km]', xs=1, charsize=csz
   cgoplot, time_array_hr_since_start, altitude_sc_io, color=cgcolor('red')
   cgoplot, time_array_hr_since_start, altitude_sc_europa, color=cgcolor('blue')
   cgoplot, time_array_hr_since_start, altitude_sc_ganymede, color=cgcolor('green')
   cgoplot, time_array_hr_since_start, altitude_sc_callisto, color=cgcolor('purple')
   cgtext,0.15,0.88,'Jupiter', /normal, charsize=csz
   cgtext,0.15,0.84,'Io', /normal, color=cgcolor('red'), charsize=csz
   cgtext,0.15,0.80,'Europa', /normal, color=cgcolor('blue'), charsize=csz
   cgtext,0.15,0.76,'Ganymede', /normal, color=cgcolor('green'), charsize=csz
   cgtext,0.15,0.72,'Callisto', /normal, color=cgcolor('purple'), charsize=csz


   window,4,xs=800,ys=500
   cgplot, time_array_hr_since_start, rate_boresight_europa_AP, yrange=[0,max(rate_boresight_europa_AP)], $
     xt='time [hr past '+time_array_utc[0]+']', yt='Rate FOV on Europa [km/s]', xs=1, charsize=csz, color=cgcolor('blue')
   cgtext,0.15,0.80,'Europa', /normal, color=cgcolor('blue'), charsize=csz
 endif

 stop

 ; Local time of the moons

 ; eclipse of the moons

 ; eclipse of the SC


 window,2,xs=1200,ys=900
 cgplot, time_array_hr_since_start, local_time_Io, yrange=[0.,24.], xt='time [hr past '+time_array_utc[0]+']', yt='Local time moons', xs=1, charsize=csz, color=cgcolor('red')
 cgoplot, time_array_hr_since_start, 10*eclipse_Io, color=cgcolor('red'), psym=10
 cgoplot, time_array_hr_since_start, local_time_Europa, color=cgcolor('blue')
 cgoplot, time_array_hr_since_start, 10*eclipse_Europa, color=cgcolor('blue'), psym=10
 cgoplot, time_array_hr_since_start, local_time_Ganymede, color=cgcolor('green')
 cgoplot, time_array_hr_since_start, 10*eclipse_Ganymede, color=cgcolor('green'), psym=10
 cgoplot, time_array_hr_since_start, local_time_Callisto, color=cgcolor('purple')
 cgoplot, time_array_hr_since_start, 10*eclipse_Callisto, color=cgcolor('purple'), psym=10
 cgtext,0.15,0.84,'Io', /normal, color=cgcolor('red'), charsize=csz
 cgtext,0.15,0.80,'Europa', /normal, color=cgcolor('blue'), charsize=csz
 cgtext,0.15,0.76,'Ganymede', /normal, color=cgcolor('green'), charsize=csz
 cgtext,0.15,0.72,'Callisto', /normal, color=cgcolor('purple'), charsize=csz




stop
end