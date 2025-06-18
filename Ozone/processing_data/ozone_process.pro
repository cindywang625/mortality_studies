pro ozone_process

spawn, 'date'

vname    = 'O3'
atmos    = 'aerosol_cmip_hourly'
usrexpt  = 'cindywang625'               ;'m1l'
;expts  = ['AM4.1_2014_hinoxhih2']
;expts = ['AM4.1_2014_lonox','AM4.1_2014_lonoxhih2','AM4.1_2014_hinox','AM4.1_2014_hinoxhih2']
;expts    = ['AM4.1_2014_hich4','AM4.1_2014_hich4hih2','AM4.1_2014_loch4','AM4.1_2014_loch4hih2']
;expts    = ['AM4.1_2014_equil','AM4.1_2014_hih2','AM4.1_2014_loh2']
;release  = 'ESM4/CMIP6/DECK/'
;platform = 'gfdl.ncrc5-intel22-prod-openmp/'
indir    ='/Volumes/bkup_srm/arise-sai-1.0/O3/001/processed/'
;next is 4

; outdir   = indir+'/pp/mda8_nobase/'

;years = ['2035','2045','2055','2065','2069'] ['2030','2031','2032','2033','2034','2035']
years_all = ['2034','2035','2036','2037','2038','2039','2040','2041','2042','2043','2044','2045','2046','2047','2048','2049','2050','2051','2052','2053','2054','2055','2056','2057','2058','2059','2060','2061','2062','2063','2064','2065','2066','2067','2068','2069']
;'2030','2031','2032','2033','2034','2035','2036','2037','2038','2039','2040','2041','2042','2043','2044','2045','2046','2047','2048',
;'2049','2050','2051','2052','2053','2054','2055','2056','2057','2058','2059','2060','2061','2062','2063','2064',$
;	'2065','2066','2067','2068','2069','2070']
;print, years

for y = 0,35 do begin ; setting the number ofyears in y to loop over (starting to count from 0, so for 10 years, y is 0,9)
    ;print, n_elements(years_)
    print, y
    year    = years_all[y]
    print, year
	; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.001.cam.h4.O3_SRF.2035010100-2045010100.nc
    ; b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-DEFAULT.008.cam.h4.O3_SRF.2061010100-2062010100.nc
	
	;if y eq 35 then begin
    ;        timetag = year + '010100-' + year + '123100'
    ;endif else begin
    timetag = year + '010100-' + years_all[y+1] + '010100'
    ;endelse

    print, timetag
        ;timetag = year+'010100-'+year+'123123'

    infile = indir + 'b.e21.BW.f09_g17.SSP245-TSMLT-GAUSS-LOWER-0.5.001.cam.h0.' + vname + '.' + timetag +'.nc
	;infile_o3s = '/archive/'+usrexpt+'/'+release+'/'+expt+'/'+platform+'/pp/atmos/ts/hourly/1yr/atmos.'+timetag+'.O3S_E90.nc'
        ;spawn, 'dmget ' + infile
        ;spawn, 'dmget ' + infile_o3s

    outdir = '/Volumes/bkup_srm/arise-sai-1.0/O3/001/processed/'
    spawn, 'mkdir -p ' + outdir
    ;spawn, 'mkdir -p ' + expt
    outfile = 'ozone_mda8_'+year+'.nc'

    ncid = ncdf_open( infile )
    ncdf_varget, ncid, 'lat', lat
    ncdf_varget, ncid, 'lon', lon
    ncdf_varget, ncid, 'time', time
    ni = n_elements(lon)
    nj = n_elements(lat)
    tothrs = n_elements(time)
    count=[ni,nj,tothrs]
    print, ni, nj, tothrs
    offset=[0,0,0,0]
    ncdf_varget, ncid, vname, indat, count=count, offset=offset
        ;ncid = ncdf_open( infile_o3s )
        ;ncdf_varget, ncid, 'O3S_E90', indat_o3s, count=count, offset=offset
    help, indat
        ;indat = reform( indat4d[*,*,0,*] )
        ;help, indat
        ;help, indat_o3s
        
        ;tothrs = n_elements(indat[0,0,*])
    ndays = tothrs/24.

    ; print # days as check
    print, year, ' Number of days in file = ', ndays

    ;fill 12/31 at beginning of file, and 1/1 for final day of file    
    dat = fltarr(ni,nj,(ndays+2)*24)
    dat[*,*,24:(tothrs+23)]=reform( indat[*,*,*] )
    dat[*,*,0:23]= reform( indat[*,*,(tothrs-24):(tothrs-1)] );12/31 
    dat[*,*,(tothrs+24):(tothrs+47)]=reform( indat[*,*,0:23] ); 1/1

        ;dat_o3s = fltarr(ni,nj,(ndays+2)*24)
        ;dat_o3s[*,*,24:(tothrs+23)]= reform( indat_o3s[*,*,0,*] )
        ;dat_o3s[*,*,0:23]= reform( indat_o3s[*,*,0,(tothrs-24):(tothrs-1)] );12/31 
        ;dat_o3s[*,*,(tothrs+24):(tothrs+47)]= reform(indat_o3s[*,*,0,0:23] ); 1/1
    print, 'begin loop'
    help, dat
        

    ozonengt=fltarr(ni,nj,ndays)
    ozoneday=fltarr(ni,nj,ndays)
    ozone8hr=fltarr(ni,nj,ndays)
    worldhr=intarr(ni,nj,ndays)
        ;ozone8hr_o3s = fltarr(ni,nj,ndays)
        
    for i=0,ni-1 do begin
        xloctm = lon[i]/15.
            
            IF ( xloctm gt 12.) THEN BEGIN ;  Western Hemisphere
                offset = 24-floor(xloctm) ;hours til new day west of GMT
                for j = 0, nj-1 do begin
                    for day = 0, ndays-1 do begin
                        ; calculation of 24 daily 8-hr values
                        mn = fix(offset) + 24*(day+1)
                        max = total(dat[i,j,mn:mn+7]) / 8.
                        maxhr = 0
                        for hr = 1, 23 do begin
                            m = mn + hr
                            max1 = total(dat[i,j,m:m+7]) / 8.
                            IF (max1 gt max) then begin
                                max = max1
                                maxhr = hr
                            ENDIF
                        endfor      ; end hr loop
                        ozone8hr[i,j,day] = max * 1.e9 ; convert to ppb
                        worldhr[i,j,day] = maxhr + 1
        ;               ozone8hr_o3s[i,j,day] = total(dat_o3s[i,j,mn+maxhr:mn+maxhr+7]) / 8. * 1.e9

                        ; calculte daytime average (8:00 to 20:00 local time)
                        nn = mn + 8
                        ozoneday[i,j,day] = total(dat[i,j,nn:nn+11]) /12. * 1.e9 ; convert to ppb
                        ozonengt[i,j,day] = total(dat[i,j,mn+20:mn+31]) /12. * 1.e9 ; convert to ppb
                        ;xx = total(dat[i,j,mn:mn+7])/8. * 1.e9 ; convert to ppb
                        ;yy = total(dat[i,j,mn+20:mn+23]) /4. * 1.e9 ; convert to ppb
                        ;ozonengt[i,j,day] = (xx+yy)/2.0 

                    endfor          ; day loop
                endfor              ; j loop
            
            ENDIF ELSE BEGIN        ; Eastern Hemisphere
                offset = -floor(xloctm) ;hours since new day entry east of GMT
                for j = 0, nj-1 do begin
                    for day = 0, ndays-1 do begin
                        mn = fix(offset) + 24*(day+1) ; midnight
                        max = total(dat[i,j,mn:mn+7]) / 8.
                        maxhr = 0
                        for hr = 1, 23 do begin
                            m = mn + hr
                            ;print, 'i=',i, ', j=', j, ',  m=', m
                            max1 = total(dat[i,j,m:m+7]) / 8.
                            IF (max1 gt max) then begin
                                max = max1
                                maxhr = hr
                            ENDIF
                        endfor      ; hr loop
                        ozone8hr[i,j,day] = max * 1.e9 ; convert to ppb
                        worldhr[i,j,day] = maxhr + 1
        ;               ozone8hr_o3s[i,j,day] = total(dat_o3s[i,j,mn+maxhr:mn+maxhr+7]) / 8. * 1.e9

                        ; calculte daytime average (8:00 to 20:00 local time)
                        nn = mn + 8
                        ozoneday[i,j,day] = total(dat[i,j,nn:nn+11]) /12. * 1.e9 ; convert to ppb
                        ozonengt[i,j,day] = total(dat[i,j,mn+20:mn+31]) /12. * 1.e9 ; convert to ppb
                    endfor          ; day loop 
                endfor              ; j loop 
            ENDELSE
        endfor                      ; i loop 

    ; write to a netcdf file

        day=indgen(ndays+1)
        day=day[1:ndays]
    ; Open netCDF file and get the file ID # (FID)
        FID = NCDF_CREATE( outfile, /CLOBBER )
        IF ( FID lt 0 ) then Message, 'Error opening file!'

    ; Set dimensions for netCDF file
        S    = SIZE( ozone8hr, /DIM ) 
        DIM1 = NCDF_DIMDEF( FID, 'lon', S[0] )
        DIM2 = NCDF_DIMDEF( FID, 'lat', S[1] )
        DIM3 = NCDF_DIMDEF( FID, 'day', S[2] )
        
    ; Write the array to the file
        varid_lon = ncdf_vardef( FID, 'lon', [DIM1], /float )
        ncdf_attput, FID, varid_lon, 'long_name', 'Longitude'  
        ncdf_attput, FID, varid_lon, 'unit', 'degrees_east'  

        varid_lat = ncdf_vardef( FID, 'lat', [DIM2], /float )
        ncdf_attput, FID, varid_lat, 'long_name', 'Latitude'  
        ncdf_attput, FID, varid_lat, 'unit', 'degrees_north'  

        varid_day = ncdf_vardef( FID, 'Day', [DIM3], /float )
        ncdf_attput, FID, varid_day, 'long_name', 'Day'
        ncdf_attput, FID, varid_day, 'unit', 'Day'  

        varid_o3 = ncdf_vardef( FID, 'mda8_o3', [DIM1,DIM2,DIM3], /float )
        ncdf_attput, FID, varid_o3, 'long_name', 'Daily max 8-hr ozone'
        ncdf_attput, FID, varid_o3, 'unit', 'ppb'

        varid_o3_day = ncdf_vardef( FID, 'daytime_o3', [DIM1,DIM2,DIM3], /float )
        ncdf_attput, FID, varid_o3_day, 'long_name', 'daytime average (8:00-20:00 LT) ozone'
        ncdf_attput, FID, varid_o3_day, 'unit', 'ppb'

        varid_o3_ngt = ncdf_vardef( FID, 'nightime_o3', [DIM1,DIM2,DIM3], /float )
        ncdf_attput, FID, varid_o3_ngt, 'long_name', 'nightime average (21:00-07:00 LT) ozone'
        ncdf_attput, FID, varid_o3_ngt, 'unit', 'ppb'

    ;    varid_o3s = ncdf_vardef( FID, 'mda8_o3se90_const', [DIM1,DIM2,DIM3], /float )
    ;    ncdf_attput, FID, varid_o3s, 'long_name', 'Daily max 8-hr ozone of stratospheric origin'
    ;    ncdf_attput, FID, varid_o3s, 'unit', 'ppb'

        varid_hr = ncdf_vardef( FID, 'hr_mda8', [DIM1,DIM2,DIM3], /float )
        ncdf_attput, FID, varid_hr, 'long_name', 'Start hour of daily max 8hr ozone' 
        ncdf_attput, FID, varid_hr, 'unit', 'LOCAL TIME'

    ; Go into netCDF DATA mode
        ncdf_control, FID, /endef

    ; put data
        ncdf_varput, FID, varid_lon,  lon
        ncdf_varput, FID, varid_lat,  lat
        ncdf_varput, FID, varid_day,  day 
        ncdf_varput, FID, varid_o3,   ozone8hr
    ; ncdf_varput, FID, varid_o3s,  ozone8hr_o3s 
        ncdf_varput, FID, varid_o3_day,ozoneday
        ncdf_varput, FID, varid_o3_ngt,ozonengt
        ncdf_varput, FID, varid_hr,   worldhr 

    ; Close the netCDF file
        NCDF_CLOSE, FID
        spawn, 'mv -f ' + outfile  + " " + outdir

spawn, 'date'
close,  /all


endfor ; year loop

end
