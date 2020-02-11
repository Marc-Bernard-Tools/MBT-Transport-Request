************************************************************************
* /MBTOOLS/BC_CTS_REQ_TEST
* MBT Request Display
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************

REPORT /mbtools/bc_cts_req_test.

TABLES:
  seometarel.

SELECT-OPTIONS:
  so_class FOR seometarel-clsname.

TYPES:
  gty_list       TYPE RANGE OF trobjtype.

DATA:
  g_class        TYPE seoclsname,
  gt_classes     TYPE TABLE OF seoclsname,
  gr_class       TYPE REF TO object,
  g_len          TYPE i,
  g_text         TYPE ddtext,
  g_icon         TYPE icon_d,
  g_type         TYPE seu_stype,
  g_object       TYPE trobjtype,
  gt_objects     TYPE TABLE OF trobjtype,
  gs_object_text TYPE ko100,
  gt_object_text TYPE TABLE OF ko100,
  gs_object_list TYPE LINE OF gty_list.

FIELD-SYMBOLS:
  <version>     TYPE string,
  <object_list> TYPE gty_list.

START-OF-SELECTION.

  gt_object_text = /mbtools/cl_objects=>get_object_texts( ).

  SELECT DISTINCT clsname FROM seometarel INTO TABLE gt_classes
    WHERE clsname IN so_class AND refclsname = '/MBTOOLS/IF_CTS_REQ_DISPLAY'
    ORDER BY clsname.

  LOOP AT gt_classes INTO g_class.
    WRITE: / 'Class:', AT 20 g_class.
    SKIP.

    CREATE OBJECT gr_class TYPE (g_class).

    ASSIGN gr_class->('C_VERSION') TO <version>.
    CHECK sy-subrc = 0.

    WRITE: / 'Version:', AT 20 <version>.
    SKIP.

    ASSIGN gr_class->('NT_OBJECT_LIST') TO <object_list>.
    CHECK sy-subrc = 0.

    LOOP AT <object_list> INTO gs_object_list.
      g_object = gs_object_list-low.

      WRITE: / 'Object:', AT 20 g_object.

*     Icon
      CALL METHOD gr_class->('GET_OBJECT_ICON')
        EXPORTING
          i_object = g_object
        CHANGING
          r_icon   = g_icon.

      WRITE: AT 30 g_icon AS ICON.

*     Text
      CLEAR g_text.

      READ TABLE gt_object_text INTO gs_object_text
        WITH KEY object = g_object. " transport objects
      IF sy-subrc = 0.
        g_text = gs_object_text-text.
      ELSE.
        SELECT SINGLE type FROM euobj INTO g_type
          WHERE id = g_object. " workbench objects
        IF sy-subrc = 0.
          SELECT SINGLE stext FROM wbobjtypt INTO g_text
            WHERE type = g_type AND spras = sy-langu.
        ELSE.
          SELECT SINGLE stext FROM wbobjtypt INTO g_text
            WHERE type = g_object AND spras = sy-langu.
        ENDIF.
        IF sy-subrc = 0.
          WRITE: AT 40 g_text.
        ENDIF.
      ENDIF.

      WRITE: AT 40 g_text.

*     Check for icon
      WRITE: AT 110 space.

      IF g_icon IS INITIAL OR g_icon = icon_dummy.
        WRITE: 'Missing icon' COLOR COL_TOTAL.
      ENDIF.

*     Check for text
      g_len = strlen( g_object ).
      IF g_text IS INITIAL.
        IF g_len < 4.
          WRITE: 'Missing text' COLOR COL_NORMAL INTENSIFIED OFF.
        ELSE.
          WRITE: 'Missing text' COLOR COL_TOTAL.
        ENDIF.
      ENDIF.

*     Check for duplicates
      READ TABLE gt_objects TRANSPORTING NO FIELDS
        WITH KEY table_line = g_object.
      IF sy-subrc = 0.
        WRITE: 'Already defined above' COLOR COL_NEGATIVE.
      ELSE.
        INSERT g_object INTO TABLE gt_objects.
      ENDIF.
    ENDLOOP.

    ULINE.
  ENDLOOP.
