CLASS /mbtools/cl_tools DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CONSTANTS:
      " Global Constant
      BEGIN OF c_reg,
        " Registry General (read-only in Registry Browser)
        general              TYPE string VALUE '.General' ##NO_TEXT,
        key_name             TYPE string VALUE 'Name' ##NO_TEXT,
        key_class            TYPE string VALUE 'Class' ##NO_TEXT,
        key_title            TYPE string VALUE 'Title' ##NO_TEXT,
        key_description      TYPE string VALUE 'Description' ##NO_TEXT,
        key_version          TYPE string VALUE 'Version' ##NO_TEXT,
        key_namespace        TYPE string VALUE 'Namespace' ##NO_TEXT,
        key_package          TYPE string VALUE 'Package' ##NO_TEXT,
        " Registry Properties (read-only in Registry Browser)
        properties           TYPE string VALUE '.Properties' ##NO_TEXT,
        key_install_time     TYPE string VALUE 'InstallTimestamp' ##NO_TEXT,
        key_install_user     TYPE string VALUE 'InstallUser' ##NO_TEXT,
        key_update_time      TYPE string VALUE 'UpdateTimestamp' ##NO_TEXT,
        key_update_user      TYPE string VALUE 'UpdateUser' ##NO_TEXT,
        " Registry Switches
        switches             TYPE string VALUE 'Switches' ##NO_TEXT,
        key_active           TYPE string VALUE 'Active' ##NO_TEXT,
        key_debug            TYPE string VALUE 'Debug' ##NO_TEXT,
        key_trace            TYPE string VALUE 'Trace' ##NO_TEXT,
        " Registry License (read-only in Registry Browser)
        license              TYPE string VALUE '.License' ##NO_TEXT,
        key_lic_id           TYPE string VALUE 'ID' ##NO_TEXT,
        key_lic_bundle       TYPE string VALUE 'BundleID' ##NO_TEXT,
        key_lic_key          TYPE string VALUE 'LicenseKey' ##NO_TEXT,
        key_lic_valid        TYPE string VALUE 'LicenseValid' ##NO_TEXT,
        key_lic_expire       TYPE string VALUE 'LicenseExpiration' ##NO_TEXT,
        " Settings
        settings             TYPE string VALUE 'Settings' ##NO_TEXT,
        " Update
        update               TYPE string VALUE '.Update' ##NO_TEXT,
        key_new_version      TYPE string VALUE 'NewVersion' ##NO_TEXT,
        key_description_html TYPE string VALUE 'DescriptionHTML' ##NO_TEXT,
        key_changelog_url    TYPE string VALUE 'ChangelogURL' ##NO_TEXT,
        key_changelog_html   TYPE string VALUE 'ChangelogHTML' ##NO_TEXT,
        key_download_url     TYPE string VALUE 'DownloadURL' ##NO_TEXT,
      END OF c_reg .
    " Evaluation
    CONSTANTS c_eval_days TYPE i VALUE 60 ##NO_TEXT.
    CONSTANTS c_eval_users TYPE i VALUE 10 ##NO_TEXT.
    CONSTANTS:
      " Actions
      BEGIN OF c_action,
        register   TYPE string VALUE 'register' ##NO_TEXT,
        unregister TYPE string VALUE 'unregister' ##NO_TEXT,
        activate   TYPE string VALUE 'activate' ##NO_TEXT,
        deactivate TYPE string VALUE 'deactivate' ##NO_TEXT,
      END OF c_action .
    DATA mbt_manifest TYPE /mbtools/if_manifest=>ty_descriptor READ-ONLY .

    " Constructor
    CLASS-METHODS class_constructor .
    METHODS constructor
      IMPORTING
        !io_tool TYPE REF TO object .
    " Class Get
    CLASS-METHODS factory
      IMPORTING
        !iv_title      TYPE csequence DEFAULT /mbtools/cl_tool_bc=>c_tool-title
      RETURNING
        VALUE(ro_tool) TYPE REF TO /mbtools/cl_tools .
    " Class Manifests
    CLASS-METHODS get_manifests
      RETURNING
        VALUE(rt_manifests) TYPE /mbtools/manifests .
    CLASS-METHODS get_tools
      IMPORTING
        VALUE(iv_pattern)     TYPE csequence OPTIONAL
        VALUE(iv_bundle_id)   TYPE i DEFAULT -1
        VALUE(iv_get_bundles) TYPE abap_bool DEFAULT abap_false
        VALUE(iv_get_tools)   TYPE abap_bool DEFAULT abap_true
        VALUE(iv_admin)       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_tools)       TYPE /mbtools/tools_with_text .
    CLASS-METHODS f4_tools
      IMPORTING
        VALUE(iv_pattern)     TYPE csequence OPTIONAL
        VALUE(iv_bundle_id)   TYPE i DEFAULT -1
        VALUE(iv_get_bundles) TYPE abap_bool DEFAULT abap_false
        VALUE(iv_get_tools)   TYPE abap_bool DEFAULT abap_true
        VALUE(iv_admin)       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_title)       TYPE string .
    " Class Actions
    CLASS-METHODS run_action
      IMPORTING
        !iv_action       TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    CLASS-METHODS install
      IMPORTING
        !iv_title        TYPE csequence
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    CLASS-METHODS update
      IMPORTING
        !io_tool         TYPE REF TO /mbtools/cl_tools
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    CLASS-METHODS uninstall
      IMPORTING
        !io_tool         TYPE REF TO /mbtools/cl_tools
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    " Tool Manifest
    METHODS build_manifest
      RETURNING
        VALUE(rs_manifest) TYPE /mbtools/if_manifest=>ty_descriptor .
    " Tool Register/Unregister
    METHODS register
      IMPORTING
        !iv_update       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS unregister
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    " Tool Activate/Deactivate
    METHODS activate
      RETURNING
        VALUE(rv_result) TYPE abap_bool
      RAISING
        /mbtools/cx_exception .
    METHODS deactivate
      RETURNING
        VALUE(rv_result) TYPE abap_bool
      RAISING
        /mbtools/cx_exception .
    METHODS is_active
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_debug
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_trace
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_base
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_bundle
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS is_last_tool
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS has_launch
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS launch .
    METHODS get_license
      IMPORTING
        !iv_param        TYPE string
      RETURNING
        VALUE(rv_result) TYPE string .
    " Tool License
    METHODS is_licensed
      IMPORTING
        !iv_check_eval   TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rv_result) TYPE abap_bool .
    METHODS license_add
      IMPORTING
        !iv_license      TYPE string
      RETURNING
        VALUE(rv_result) TYPE abap_bool
      RAISING
        /mbtools/cx_exception .
    METHODS license_remove
      RETURNING
        VALUE(rv_result) TYPE abap_bool
      RAISING
        /mbtools/cx_exception .
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
    METHODS get_bundle_id
      RETURNING
        VALUE(rv_result) TYPE i .
    METHODS get_download_id
      RETURNING
        VALUE(rv_result) TYPE i .
    METHODS get_html_changelog
      RETURNING
        VALUE(rv_result) TYPE string .
    METHODS get_description
      RETURNING
        VALUE(rv_description) TYPE string .
    METHODS get_html_description
      RETURNING
        VALUE(rv_result) TYPE string .
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
    METHODS get_url_download
      RETURNING
        VALUE(rv_result) TYPE string .
    METHODS get_url_changelog
      RETURNING
        VALUE(rv_result) TYPE string .
    METHODS get_settings
      RETURNING
        VALUE(ro_reg) TYPE REF TO /mbtools/cl_registry .
    METHODS get_new_version
      RETURNING
        VALUE(rv_result) TYPE string .
    METHODS get_thumbnail
      RETURNING
        VALUE(rv_thumbnail) TYPE string .
    METHODS get_last_update
      RETURNING
        VALUE(rv_result) TYPE string .
    METHODS check_version
      RETURNING
        VALUE(rv_result) TYPE abap_bool
      RAISING
        /mbtools/cx_exception .
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
  METHOD build_manifest.
  ENDMETHOD.
  METHOD get_thumbnail.
  ENDMETHOD.
  METHOD is_bundle.
  ENDMETHOD.
  METHOD get_bundle_id.
  ENDMETHOD.
  METHOD has_launch.
  ENDMETHOD.
  METHOD get_last_update.
  ENDMETHOD.
  METHOD launch.
  ENDMETHOD.
  METHOD is_base.
  ENDMETHOD.
  METHOD is_last_tool.
  ENDMETHOD.
  METHOD is_active.
  ENDMETHOD.
  METHOD is_debug.
  ENDMETHOD.
  METHOD is_trace.
  ENDMETHOD.
  METHOD get_download_id.
  ENDMETHOD.
  METHOD get_license.
  ENDMETHOD.
  METHOD check_version.
  ENDMETHOD.
  METHOD get_new_version.
  ENDMETHOD.
  METHOD get_url_changelog.
  ENDMETHOD.
  METHOD get_url_download.
  ENDMETHOD.
  METHOD get_html_changelog.
  ENDMETHOD.
  METHOD get_html_description.
  ENDMETHOD.
  METHOD install.
  ENDMETHOD.
  METHOD uninstall.
  ENDMETHOD.
  METHOD update.
  ENDMETHOD.
ENDCLASS.