

" INIT --------------------------------------------------------------------------"

method IF_EX_MB_MIGO_BADI~INIT.
  APPEND gf_class_id TO ct_init.
endmethod.



" PBO_DETAIL --------------------------------------------------------------------------"

METHOD if_ex_mb_migo_badi~pbo_detail.

  DATA: lwa_extdata   TYPE zst_mseg_presu,
        ls_idmemo(50) TYPE c.

  IF g_tab_presu IS NOT INITIAL.

    CHECK i_class_id = gf_class_id.

    IF g_no_input IS INITIAL.
      e_cprog     = 'ZSAPLMIGO_BADI_D'.
      e_dynnr     = '0100'. "input
      e_heading   = 'Código Presupuestal'(004).
    ELSE.
      e_cprog     = 'ZSAPLMIGO_BADI_D'.
      e_dynnr     = '0200'. "display
      e_heading   = 'Código Presupuestal'(004).
    ENDIF.

    g_line_id   = i_line_id.

    CLEAR: ls_idmemo.
    CONCATENATE 'ZMIGO-COD_PRESUP-' sy-uname INTO ls_idmemo.

    READ TABLE gt_extdata INTO lwa_extdata WITH KEY line_id = g_line_id.
    IF sy-subrc EQ 0.
      EXPORT xdata_cod_presup FROM lwa_extdata-cod_presup TO MEMORY ID ls_idmemo.
    ENDIF.

  ENDIF.

ENDMETHOD.



" PAI_DETAIL --------------------------------------------------------------------------"

method IF_EX_MB_MIGO_BADI~PAI_DETAIL.
  e_force_change = 'X'.
endmethod.




" LINE_MODIFY --------------------------------------------------------------------------"

METHOD if_ex_mb_migo_badi~line_modify.

  DATA: lwa_extdata    TYPE zst_mseg_presu,
        lwa_mseg_presu TYPE ztbmm_mseg_presu,
        ls_bukrs       TYPE ekpo-bukrs,
        ls_idmemo(50)  TYPE c.

  CLEAR: g_tab_presu, ls_bukrs.

  SELECT SINGLE bukrs INTO ls_bukrs
    FROM ekpo
    WHERE ebeln = cs_goitem-ebeln
      AND ebelp = cs_goitem-ebelp.
  IF sy-subrc EQ 0.
    IF ls_bukrs EQ '1000'. "solo para sociedad 1000
      g_tab_presu = 'X'.
    ENDIF.
  ENDIF.

  IF g_tab_presu IS NOT INITIAL.

    "get data from screen
    CLEAR: ls_idmemo.
    CONCATENATE 'ZMIGO-COD_PRESUP-' sy-uname INTO ls_idmemo.
    IMPORT xdata_cod_presup TO lwa_mseg_presu-cod_presup FROM MEMORY ID ls_idmemo.
    FREE MEMORY ID ls_idmemo.

    CHECK lwa_mseg_presu-cod_presup IS NOT INITIAL.

    IF cs_goitem-mblnr IS NOT INITIAL AND
       cs_goitem-mjahr IS NOT INITIAL AND
       cs_goitem-zeile IS NOT INITIAL.

      lwa_extdata-line_id    = i_line_id.
      lwa_extdata-mblnr      = cs_goitem-mblnr.
      lwa_extdata-mjahr      = cs_goitem-mjahr.
      lwa_extdata-zeile      = cs_goitem-zeile.
      lwa_extdata-ebeln      = cs_goitem-ebeln.
      lwa_extdata-ebelp      = cs_goitem-ebelp.
      lwa_extdata-cod_presup = lwa_mseg_presu-cod_presup.

      DELETE gt_extdata WHERE line_id = lwa_extdata-line_id.
      INSERT lwa_extdata INTO TABLE gt_extdata.

    ELSE.

      lwa_extdata-line_id    = i_line_id.
      lwa_extdata-ebeln      = cs_goitem-ebeln.
      lwa_extdata-ebelp      = cs_goitem-ebelp.
      lwa_extdata-cod_presup = lwa_mseg_presu-cod_presup.

      DELETE gt_extdata WHERE line_id = lwa_extdata-line_id.
      INSERT lwa_extdata INTO TABLE gt_extdata.

    ENDIF.
  ENDIF.

ENDMETHOD.



" RESET --------------------------------------------------------------------------"

method IF_EX_MB_MIGO_BADI~RESET.

  REFRESH: gt_extdata.
  CLEAR: g_no_input, gs_exdata_header, g_cancel, g_line_id.

endmethod.



" POST_DOCUMENT --------------------------------------------------------------------------"

METHOD if_ex_mb_migo_badi~post_document.

  DATA: lwa_mseg_presu TYPE ztbmm_mseg_presu,
        ltd_mseg_presu TYPE TABLE OF ztbmm_mseg_presu,
        lwa_mseg       TYPE mseg,
        lwa_extdata    TYPE zst_mseg_presu.

  LOOP AT it_mseg INTO lwa_mseg.
    READ TABLE gt_extdata INTO lwa_extdata WITH KEY line_id = lwa_mseg-line_id.
    IF sy-subrc = 0.
      MOVE-CORRESPONDING lwa_mseg TO lwa_extdata.
      MOVE-CORRESPONDING lwa_extdata TO lwa_mseg_presu.
      APPEND lwa_mseg_presu TO ltd_mseg_presu.
    ENDIF.
  ENDLOOP.

  IF ltd_mseg_presu[] IS NOT INITIAL.
    MODIFY ztbmm_mseg_presu FROM TABLE ltd_mseg_presu.
  ENDIF.

ENDMETHOD.



" CHECK_ITEM --------------------------------------------------------------------------"

METHOD if_ex_mb_migo_badi~check_item.

  DATA: ltd_cod_presup TYPE STANDARD TABLE OF ztbmm_cod_presup,
        lwa_extdata    TYPE zst_mseg_presu,
        lwa_bapiret    TYPE bapiret2,
        ls_idmemo(50)  TYPE c.

  SELECT * INTO TABLE ltd_cod_presup
    FROM ztbmm_cod_presup.
*    WHERE bukrs EQ bukrs.

  READ TABLE gt_extdata INTO lwa_extdata WITH KEY line_id = i_line_id.
  IF sy-subrc EQ 0.

    IF lwa_extdata-cod_presup IS NOT INITIAL.
      READ TABLE ltd_cod_presup WITH KEY cod_presup = lwa_extdata-cod_presup TRANSPORTING NO FIELDS.
      IF sy-subrc NE 0.
        "error message: codigo presupuestal es invalido
        CLEAR lwa_bapiret.
        lwa_bapiret-type       = 'E'.
        lwa_bapiret-id         = 'M7'.
        lwa_bapiret-number     = '895'.
        lwa_bapiret-message_v1 = 'Código presupuestal inválido'.
        APPEND lwa_bapiret TO et_bapiret2.
*        MESSAGE 'Código presupuestal inválido' TYPE 'E'.
      ENDIF.
    ELSE.
      "error message: falta indicar codigo presupuestal
      CLEAR lwa_bapiret.
      lwa_bapiret-type       = 'E'.
      lwa_bapiret-id         = 'M7'.
      lwa_bapiret-number     = '895'.
      lwa_bapiret-message_v1 = 'Ingresar Código presupuestal'.
      APPEND lwa_bapiret TO et_bapiret2.
*      MESSAGE 'Ingresar Código presupuestal' TYPE 'E'.
    ENDIF.

  ENDIF.

  CLEAR: ls_idmemo.
  CONCATENATE 'ZMIGO-COD_PRESUP_T-' sy-uname INTO ls_idmemo.
  FREE MEMORY ID ls_idmemo.

  IF gt_extdata[] IS NOT INITIAL.
    EXPORT xdata_cod_presup_t FROM gt_extdata TO MEMORY ID ls_idmemo.
  ENDIF.

ENDMETHOD.




" MODE_SET --------------------------------------------------------------------------"

METHOD if_ex_mb_migo_badi~mode_set.

  CLEAR: g_no_input.
  IF i_action = 'A04'.
    g_no_input = 'X'.
  ENDIF.

  IF i_action = 'A03'.
    g_cancel = 'X'.
  ENDIF.

ENDMETHOD.
