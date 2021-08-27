*&---------------------------------------------------------------------*
*&  Include           ZSAPLMIGO_BADI_D_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  GET_DATA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_data INPUT.

  CLEAR: gs_idmemo.
  CONCATENATE 'ZMIGO-COD_PRESUP-' sy-uname INTO gs_idmemo.
  EXPORT xdata_cod_presup FROM gwa_mseg_presu-cod_presup TO MEMORY ID gs_idmemo.

ENDMODULE.                 " GET_DATA  INPUT
*&---------------------------------------------------------------------*
*&      Module  Z_DISPLAY_HS_COD_PRESUP  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE z_display_hs_cod_presup INPUT.

  DATA: ltd_cod_presup1 TYPE TABLE OF ztbmm_cod_presup,
        ltd_return      LIKE ddshretval OCCURS 0 WITH HEADER LINE,
        lw_dynprofield  TYPE help_info-dynprofld,
        ls_ebeln1        TYPE ekko-ebeln,
        ls_bukrs1       TYPE ekko-bukrs.

  FIELD-SYMBOLS: <fs_bukrs1> TYPE ekko-bukrs,
                 <fs_ebeln1> TYPE ekko-ebeln.

  CLEAR: ls_ebeln1, ls_bukrs1.

  IF sy-tcode EQ 'MIGO'.
  ELSE.
    EXIT.
  ENDIF.

  IF ls_bukrs1 IS INITIAL.
    ls_bukrs1 = '1000'.
  ENDIF.

  SELECT * INTO TABLE ltd_cod_presup1
    FROM ztbmm_cod_presup
    WHERE bukrs EQ ls_bukrs1
    ORDER BY cod_presup.

  IF sy-subrc EQ 0.

    lw_dynprofield = 'GOSERIAL-ZZCOD_PRESUP'.

    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield    = 'COD_PRESUP'
        dynpprog    = sy-cprog
        dynpnr      = sy-dynnr
        dynprofield = lw_dynprofield
        value_org   = 'S'
      TABLES
        value_tab   = ltd_cod_presup1
        return_tab  = ltd_return.

  ENDIF.

ENDMODULE.                 " Z_DISPLAY_HS_COD_PRESUP  INPUT