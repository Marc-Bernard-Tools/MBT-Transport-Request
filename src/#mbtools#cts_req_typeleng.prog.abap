*----------------------------------------------------------------------*
*   INCLUDE TTYPLENG                                                   *
*----------------------------------------------------------------------*

CONSTANTS: gc_ddic       TYPE i  VALUE '30',      "new 30
           gc_sqlt       TYPE i  VALUE '10',
           gc_prog       TYPE i  VALUE '40',      "new 40
           gc_vari       TYPE i  VALUE '14',
           gc_fsel       TYPE i  VALUE '40',      "new 40, = gc_prog
           gc_ssct       TYPE i  VALUE '40',      "new 40, = gc_prog
           gc_cuad       TYPE i  VALUE '40',      "new 40, = gc_prog
           gc_dynp       TYPE i  VALUE '4',
           gc_func       TYPE i  VALUE '30',
           gc_intd       TYPE i  VALUE '30' ,
           gc_fugr       TYPE i  VALUE '26',      "new 26
           gc_comm       TYPE i  VALUE '20',      "new 20
           gc_msag       TYPE i  VALUE '20',      "new 20
           gc_mess       TYPE i  VALUE '3',
           gc_indx       TYPE i  VALUE '3',
           gc_enqu       TYPE i  VALUE '30',      "new 30
           gc_mcid       TYPE i  VALUE '5',
           gc_mcob       TYPE i  VALUE '4',
           gc_iwom       TYPE i  VALUE '17',

*** older definiion of matchcodes MCOD with text MCOX and add field mcof
           gc_mcod       TYPE i  VALUE '10',
           gc_type       TYPE i  VALUE '5',
*** most documentation is of length 30 ********************************
           gc_docu       TYPE i  VALUE '30',
*** however general restriction from docu-tools is 60 *****************
           gc_docu_l     TYPE i  VALUE '60',
           gc_syag       TYPE i  VALUE '2',
           gc_ldba       TYPE i  VALUE '20',      "new 20
           gc_tran       TYPE i  VALUE '20',      "new 20
           gc_dial       TYPE i  VALUE '30',
           gc_para       TYPE i  VALUE '20',      "new 20
           gc_styl       TYPE i  VALUE '8',       "new 8
           gc_form       TYPE i  VALUE '16',      "new 16
           gc_devc       TYPE i  VALUE '30',      "new 30
           gc_char       TYPE i  VALUE '30',      "new 30
           gc_sobj       TYPE i  VALUE '40',      "new 40(10+30)
           gc_sobjm      TYPE i  VALUE '10',  "part1:length of main sobj
           gc_sobjm_2    TYPE i  VALUE '12',    "offset: gc_objm+2('OD'
           gc_sobjs      TYPE i  VALUE '30',  "part1:length of sub sobj
           gc_dsel       TYPE i  VALUE '40',      "new 40
           gc_dsyo       TYPE i  VALUE '30',"actually 13, leave it(ag)
           gc_dsys_r3tr  TYPE i  VALUE '40',      "new 40
           gc_dsys_r3ob  TYPE i  VALUE '25',
           gc_prin       TYPE i  VALUE '30',
           gc_guifu      TYPE i  VALUE '4',
*** DE details docu, gui menu docu and gui function docu have an ******
*** additional part of length 4 after docu-ID                    ******
           gc_docu_ext   TYPE i  VALUE '4',
           gc_appl       TYPE i  VALUE '4',
           gc_chdo       TYPE i  VALUE '15',      "new 15
           gc_feat       TYPE i  VALUE '8',
           gc_nrob       TYPE i  VALUE '10',
           gc_synd       TYPE i  VALUE '30',      "new 30 - note 1411986
           gc_tobj       TYPE i  VALUE '31',      "new 31
           gc_trob       TYPE i  VALUE '4',
           gc_docu_prefix TYPE i  VALUE '2'.
CONSTANTS: gc_cntx       TYPE i  VALUE '20',
           gc_pinf       TYPE i  VALUE '30',
*** constants for OO transport objects (ABAP class etc.) **************
           gc_clas       TYPE i  VALUE '30',
           gc_meth       TYPE i  VALUE '61',
           gc_intf       TYPE i  VALUE '30',
           gc_sott       TYPE i  VALUE '32',
           gc_wapa       TYPE i  VALUE '30',
           gc_wapp       TYPE i  VALUE '70'.
*** constants for Web Dynpro ***
CONSTANTS: gc_wdyn       TYPE i  VALUE '30',
           gc_wdyc       TYPE i  VALUE '30',
           gc_wdyv       TYPE i  VALUE '30'.
*** constants for Hana Objects Transport (HOT) in ABAP ***
CONSTANTS: gc_hota       TYPE i  VALUE '40',
           gc_hoto       TYPE i  VALUE '70'. "Maximum length = 110 due to restrictions in versioning -> 40 for HOTA + 70 for HOTO

CONSTANTS: gc_ddic_old      TYPE i  VALUE '10',
           gc_sqlt_old      TYPE i  VALUE '10',
           gc_prog_old      TYPE i  VALUE '8',
           gc_vari_old      TYPE i  VALUE '14',
           gc_fsel_old      TYPE i  VALUE '8',
           gc_ssct_old      TYPE i  VALUE '8',
           gc_cuad_old      TYPE i  VALUE '8',
           gc_dynp_old      TYPE i  VALUE '4',
           gc_func_old      TYPE i  VALUE '30',
           gc_fugr_old      TYPE i  VALUE '4',
           gc_comm_old      TYPE i  VALUE '10',
           gc_msag_old      TYPE i  VALUE '2',
           gc_mess_old      TYPE i  VALUE '3',
           gc_indx_old      TYPE i  VALUE '3',
           gc_enqu_old      TYPE i  VALUE '10',
           gc_mcid_old      TYPE i  VALUE '5',
           gc_mcob_old      TYPE i  VALUE '4',
           gc_intd_old      TYPE i  VALUE '30',
*** older definiion of matchcodes MCOD with text MCOX and add field MCOF
           gc_mcod_old      TYPE i  VALUE '10',
           gc_type_old      TYPE i  VALUE '5',
*** most documentation is of length 30 ********************************
           gc_docu_old      TYPE i  VALUE '30',
*** however general restriction from docu-tools is 60 *****************
           gc_docu_l_old    TYPE i  VALUE '60',
           gc_syag_old      TYPE i  VALUE '2',
           gc_ldba_old      TYPE i  VALUE '3',
           gc_tran_old      TYPE i  VALUE '4',
           gc_dial_old      TYPE i  VALUE '30',
           gc_para_old      TYPE i  VALUE '3',
           gc_styl_old      TYPE i  VALUE '30',
           gc_form_old      TYPE i  VALUE '30',
           gc_devc_old      TYPE i  VALUE '4',
           gc_dsel_old      TYPE i  VALUE '26',
           gc_dsyo_old      TYPE i  VALUE '30',
           gc_dsys_r3tr_old TYPE i  VALUE '30',
           gc_dsys_r3ob_old TYPE i  VALUE '25',
           gc_prin_old      TYPE i  VALUE '30',
           gc_guifu_old     TYPE i  VALUE '4',
*** DE details docu, gui menu docu and gui function docu have an ******
*** additional part of length 4 after docu-ID                    ******
           gc_docu_ext_old  TYPE i  VALUE '4',
           gc_appl_old      TYPE i  VALUE '4',
           gc_chdo_old      TYPE i  VALUE '10',
           gc_feat_old      TYPE i  VALUE '8',
           gc_nrob_old      TYPE i  VALUE '10',
           gc_synd_old      TYPE i  VALUE '24',
           gc_tobj_old      TYPE i  VALUE '11',
           gc_trob_old      TYPE i  VALUE '4',
           gc_docu_prefix_old TYPE i  VALUE '2'.
