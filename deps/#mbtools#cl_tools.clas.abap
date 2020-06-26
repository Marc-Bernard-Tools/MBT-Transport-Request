************************************************************************
* /MBTOOLS/CL_TOOLS
* MBT Tool Manager
*
* (c) MBT 2020 https://marcbernardtools.com/
************************************************************************
CLASS /mbtools/cl_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    " Global Constant
    CONSTANTS c_github TYPE string VALUE 'github.com/mbtools' ##NO_TEXT.
    CONSTANTS c_home TYPE string VALUE 'https://marcbernardtools.com/' ##NO_TEXT.
    CONSTANTS c_terms TYPE string VALUE 'https://marcbernardtools.com/company/terms-software/' ##NO_TEXT.
    CONSTANTS c_namespace TYPE devclass VALUE '/MBTOOLS/' ##NO_TEXT.
    CONSTANTS c_manifest TYPE seoclsname VALUE '/MBTOOLS/IF_MANIFEST' ##NO_TEXT.
    CONSTANTS:
      BEGIN OF c_reg,
        " Registry General
        general            TYPE string VALUE 'General^' ##NO_TEXT,
        key_name           TYPE string VALUE 'Name' ##NO_TEXT,
        key_class          TYPE string VALUE 'Class' ##NO_TEXT,
        key_title          TYPE string VALUE 'Title' ##NO_TEXT,
        key_description    TYPE string VALUE 'Description' ##NO_TEXT,
        key_version        TYPE string VALUE 'Version' ##NO_TEXT,
        key_namespace      TYPE string VALUE 'Namespace' ##NO_TEXT,
        key_package        TYPE string VALUE 'Package' ##NO_TEXT,
        " Registry Properties
        properties         TYPE string VALUE 'Properties^' ##NO_TEXT,
        key_install_time   TYPE string VALUE 'InstallTimestamp' ##NO_TEXT,
        key_install_user   TYPE string VALUE 'InstallUser' ##NO_TEXT,
        key_uninstall_time TYPE string VALUE 'UninstallTimestamp' ##NO_TEXT,
        key_uninstall_user TYPE string VALUE 'UninstallUser' ##NO_TEXT,
        key_update_time    TYPE string VALUE 'UpdateTimestamp' ##NO_TEXT,
        key_update_user    TYPE string VALUE 'UpdateUser' ##NO_TEXT,
        " Registry Switches
        switches           TYPE string VALUE 'Switches' ##NO_TEXT,
        key_active         TYPE string VALUE 'Active' ##NO_TEXT,
        key_debug          TYPE string VALUE 'Debug' ##NO_TEXT,
        key_trace          TYPE string VALUE 'Trace' ##NO_TEXT,
        " Registry License
        license            TYPE string VALUE 'License^' ##NO_TEXT,
        key_lic_id         TYPE string VALUE 'ID' ##NO_TEXT,
        key_lic_bundle     TYPE string VALUE 'BundleID' ##NO_TEXT,
        key_lic_key        TYPE string VALUE 'LicenseKey' ##NO_TEXT,
        key_lic_valid      TYPE string VALUE 'LicenseValid' ##NO_TEXT,
        key_lic_expire     TYPE string VALUE 'LicenseExpiration' ##NO_TEXT,
        " Settings
        settings           TYPE string VALUE 'Settings' ##NO_TEXT,
      END OF c_reg .
    " Evaluation
    CONSTANTS c_eval_days TYPE i VALUE 30 ##NO_TEXT.
    CONSTANTS c_eval_users TYPE i VALUE 10 ##NO_TEXT.
    CONSTANTS:
      " Actions
      BEGIN OF c_action,
        register   TYPE string VALUE 'register',
        unregister TYPE string VALUE 'unregister',
        activate   TYPE string VALUE 'activate',
        deactivate TYPE string VALUE 'deactivate',
      END OF c_action .
    DATA apack_manifest TYPE /mbtools/if_apack_manifest=>ty_descriptor READ-ONLY .
    DATA mbt_manifest TYPE /mbtools/if_manifest=>ty_descriptor READ-ONLY .

    " Constructor
    CLASS-METHODS class_constructor .
    METHODS constructor
      IMPORTING
        !io_tool TYPE REF TO object .
    " Class Get
    CLASS-METHODS factory
      IMPORTING
        VALUE(iv_title) TYPE csequence
      RETURNING
        VALUE(ro_tool)  TYPE REF TO /mbtools/cl_tools .
    CLASS-METHODS get_tools
      IMPORTING
        VALUE(iv_pattern) TYPE csequence OPTIONAL
      RETURNING
        VALUE(rt_tools)   TYPE /mbtools/tools_with_text .
    CLASS-METHODS f4_tools
      IMPORTING
        VALUE(iv_pattern) TYPE csequence OPTIONAL
      RETURNING
        VALUE(rv_title)   TYPE string .
    " Class Actions
    CLASS-METHODS run_action
      IMPORTING
        VALUE(iv_action) TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    " Class Manifests
    CLASS-METHODS get_manifests
      RETURNING
        VALUE(rt_manifests) TYPE /mbtools/manifests .
    " Tool Manifest
    METHODS build_apack_manifest
      RETURNING
        VALUE(rs_manifest) TYPE /mbtools/if_apack_manifest=>ty_descriptor .
    METHODS build_mbt_manifest
      RETURNING
        VALUE(rs_manifest) TYPE /mbtools/if_manifest=>ty_descriptor .
    " Tool Register/Unregister
    METHODS register
      RETURNING
        VALUE(rv_registered) TYPE abap_bool .
    METHODS unregister
      RETURNING
        VALUE(rv_unregistered) TYPE abap_bool .
    " Tool Activate/Deactivate
    METHODS activate
      RETURNING
        VALUE(rv_activated) TYPE abap_bool .
    METHODS deactivate
      RETURNING
        VALUE(rv_deactivated) TYPE abap_bool .
    METHODS is_active
      RETURNING
        VALUE(rv_active) TYPE abap_bool .
    " Tool License
    METHODS is_licensed
      RETURNING
        VALUE(rv_licensed) TYPE abap_bool .
    METHODS license_add
      IMPORTING
        VALUE(iv_license)  TYPE string
      RETURNING
        VALUE(rv_licensed) TYPE abap_bool .
    METHODS license_remove
      RETURNING
        VALUE(rv_removed) TYPE abap_bool .
    " Tool Get
    METHODS get_id
      RETURNING
        VALUE(rv_id) TYPE string .
    METHODS get_slug
      RETURNING
        VALUE(rv_slug) TYPE string .
    METHODS get_name
      RETURNING
        VALUE(rv_name) TYPE string .
    METHODS get_title
      RETURNING
        VALUE(rv_title) TYPE string .
    METHODS get_version
      RETURNING
        VALUE(rv_version) TYPE string .
    METHODS get_description
      RETURNING
        VALUE(rv_description) TYPE string .
    METHODS get_class
      RETURNING
        VALUE(rv_class) TYPE string .
    METHODS get_package
      RETURNING
        VALUE(rv_package) TYPE devclass .
    METHODS get_url_repo
      RETURNING
        VALUE(rv_url) TYPE string .
    METHODS get_url_tool
      RETURNING
        VALUE(rv_url) TYPE string .
    METHODS get_url_docs
      RETURNING
        VALUE(rv_url) TYPE string .
    METHODS get_settings
      RETURNING
        VALUE(ro_reg) TYPE REF TO /mbtools/cl_registry .
ENDCLASS.
CLASS /mbtools/cl_tools IMPLEMENTATION.
  METHOD activate.
  ENDMETHOD.
  METHOD class_constructor.
  ENDMETHOD.
  METHOD constructor.
  ENDMETHOD.
  METHOD deactivate.
  ENDMETHOD.
  METHOD is_active.
  ENDMETHOD.
  METHOD is_licensed.
  ENDMETHOD.
  METHOD license_add.
  ENDMETHOD.
  METHOD license_remove.
  ENDMETHOD.
  METHOD register.
  ENDMETHOD.
  METHOD unregister.
  ENDMETHOD.
  METHOD get_name.
  ENDMETHOD.
  METHOD get_slug.
  ENDMETHOD.
  METHOD get_package.
  ENDMETHOD.
  METHOD get_url_docs.
  ENDMETHOD.
  METHOD get_url_repo.
  ENDMETHOD.
  METHOD get_url_tool.
  ENDMETHOD.
  METHOD build_apack_manifest.
  ENDMETHOD.
  METHOD build_mbt_manifest.
  ENDMETHOD.
  METHOD f4_tools.
  ENDMETHOD.
  METHOD get_class.
  ENDMETHOD.
  METHOD get_tools.
  ENDMETHOD.
  METHOD get_manifests.
  ENDMETHOD.
  METHOD get_id.
  ENDMETHOD.
  METHOD get_title.
  ENDMETHOD.
  METHOD get_version.
  ENDMETHOD.
  METHOD get_description.
  ENDMETHOD.
  METHOD run_action.
  ENDMETHOD.
  METHOD factory.
  ENDMETHOD.
  METHOD get_settings.
  ENDMETHOD.
ENDCLASS.