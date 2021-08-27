*&---------------------------------------------------------------------*
*&  Include           ZSAPLMIGO_BADI_D_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  CLEAR: gs_idmemo.
  CONCATENATE 'ZMIGO-COD_PRESUP-' sy-uname INTO gs_idmemo.
  IMPORT xdata_cod_presup TO gwa_mseg_presu-cod_presup FROM MEMORY ID gs_idmemo.
  FREE MEMORY ID gs_idmemo.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  CLEAR: gs_idmemo.
  CONCATENATE 'ZMIGO-COD_PRESUP-' sy-uname INTO gs_idmemo.
  IMPORT xdata_cod_presup TO gwa_mseg_presu-cod_presup FROM MEMORY ID gs_idmemo.
  FREE MEMORY ID gs_idmemo.

ENDMODULE.                 " STATUS_0200  OUTPUT