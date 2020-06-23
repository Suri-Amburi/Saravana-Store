class ZCL_MOBILE_SYSTEM_LOGIN definition
  public
  inheriting from CL_ICF_SYSTEM_LOGIN
  create public .

*"* public components of class ZCL_MOBILE_SYSTEM_LOGIN
*"* do not include other source files here!!!
public section.

  constants CO_ITS_FORM_LOGIN type STRING value 'MobileLoginForm' ##NO_TEXT.
  constants CO_ITS_JS_SUBMIT_CHANGEPWD type STRING value 'MobileSubmitChangePwd' ##NO_TEXT.
  constants CO_ITS_JS_SUBMIT_CONTINUE type STRING value 'MobileSubmitContinue' ##NO_TEXT.
  constants CO_ITS_JS_SUBMIT_LOGIN type STRING value 'MobileSubmitLogin' ##NO_TEXT.
  constants CO_ITS_JS_SUBMIT_QUERYSESS type STRING value 'MobileSubmitQuerySession' ##NO_TEXT.

  methods CONSTRUCTOR
    importing
      !II_SERVER type ref to IF_HTTP_SERVER .

  methods HTM_CHANGE_PASSWD
    redefinition .
  methods HTM_LOGIN
    redefinition .
  methods HTM_MESSAGE_BOX
    redefinition .
  methods HTM_SESSION_QUERY
    redefinition .
  methods HTM_SYSTEM_MESSAGE
    redefinition .
protected section.
*"* protected components of class ZCL_MOBILE_SYSTEM_LOGIN
*"* do not include other source files here!!!

  methods WRITE_CONTENT_BEGIN_HTML
    importing
      !CONTENT_TITLE type STRING
      !CONTENT_JS type STRING
      !CONTENT_ONKEYDOWN type STRING
      !CONTENT_ONLOAD type STRING
      !CONTENT_HIDDENFIELDS type STRING
    changing
      !RV_HTML type STRING .
  methods WRITE_CONTENT_END_HTML
    changing
      !RV_HTML type STRING .
  methods WRITE_MESSAGE_HTML
    changing
      !RV_HTML type STRING .
  methods WRITE_CSS_STYLE
    returning
      value(RV_CSS_STYLE) type STRING .

  methods WRITE_JS_FUNCTIONS
    redefinition .
  methods WRITE_JS_HTML_FUNCTIONS
    redefinition .
private section.
*"* private components of class ZCL_MOBILE_SYSTEM_LOGIN
*"* do not include other source files here!!!

  types:
    begin of T_SYS_MESSAGE,
    id     type string,
    author type string,
    html   type string,
    end of t_sys_message .
  types:
    T_SYS_MESSAGE_TAB type standard table of t_sys_message with default key .
  types:
    T_TeMSG_TAB type standard table of temsg with default key .

  methods FORMAT_SYSTEM_MESSAGES
    importing
      !TEMSGS type T_TEMSG_TAB
    returning
      value(MESSAGES) type T_SYS_MESSAGE_TAB .
ENDCLASS.



CLASS ZCL_MOBILE_SYSTEM_LOGIN IMPLEMENTATION.


method CONSTRUCTOR.
*CALL METHOD SUPER->CONSTRUCTOR
super->constructor( ii_server = ii_server ).

* --- set delete session time
me->m_delete_session_time = 0.

endmethod.


method FORMAT_SYSTEM_MESSAGES.

  data index_at_1 type i.
  data index_at_2 type i.
  data offset type i.
  data offset_2 type i.
  data last_offset type i.
  data length type i.
  data html_in type string.
  data icon type string.
  data icon_url type string.
  data temsg type temsg.
  data num_rows type i.
  field-symbols <message> type t_sys_message.

  loop at temsgs into temsg.

    if num_rows = 0.
      num_rows = temsg-norow.
      insert initial line into table messages assigning <message>.
      html_in = temsg-id.
      <message>-id = CL_ABAP_DYN_PRG=>ESCAPE_XSS_XML_HTML( html_in ).
      html_in = temsg-author.
      <message>-author = CL_ABAP_DYN_PRG=>ESCAPE_XSS_XML_HTML( html_in ).
    else.
      concatenate <message>-html ` ` into <message>-html.
    endif.
    subtract 1 from num_rows.

    html_in = temsg-emtext.
    html_in = CL_ABAP_DYN_PRG=>ESCAPE_XSS_XML_HTML( html_in ).
    last_offset = 0.

    " Make URL clickable
    find 'http://' in html_in match offset offset. "#EC NOTEXT
    if sy-subrc <> 0.
      find 'https://' in html_in match offset offset.       "#EC NOTEXT
    endif.
    if sy-subrc = 0.
      find ` ` in html_in+offset match offset length.
      if sy-subrc <> 0.
        length = strlen( html_in+offset ).
      endif.
      find `"` in section length length of html_in+offset.
      if sy-subrc <> 0.
        offset_2 = offset + length.
        concatenate html_in+0(offset) '<a href="' html_in+offset(length) '" target="_blank">' html_in+offset(length) '</a>' html_in+offset_2 into html_in."#EC NOTEXT
      endif.
    endif.

    " Replace icons
    do.
      " find @
      find '@' in html_in+last_offset match offset offset.
      if sy-subrc <> 0.
        concatenate <message>-html html_in+last_offset into <message>-html.
        exit.
      endif.

      " concatenate string
      concatenate <message>-html html_in+last_offset(offset) into <message>-html.
      last_offset = last_offset + offset.

      index_at_1 = last_offset.
      offset = index_at_1 + 1.
      " find second @
      find '@' in section offset offset of html_in match offset index_at_2.
      if sy-subrc = 0.
        length = index_at_2 - index_at_1.
        if length = 3.
          icon     = html_in+index_at_1(4). " @..@
          icon_url = cl_bsp_mimes=>sap_icon( icon ).
          concatenate <message>-html ` <img src="` icon_url `" align="left">&nbsp;` into <message>-html."#EC NOTEXT
          last_offset = index_at_2 + 1.
          continue.
        endif.
      endif.

      last_offset = last_offset + 1.
      concatenate <message>-html '@' into <message>-html.
    enddo.

  endloop.

endmethod.


method HTM_CHANGE_PASSWD.
*CALL METHOD SUPER->HTM_CHANGE_PASSWD
*  EXPORTING
*    IV_JAVASCRIPT    =
*    IV_HIDDEN_FIELDS =
*  RECEIVING
*    RV_HTML          =
*    .
* --- content begin / title
  DATA: lv_pwd_old_style      type boole_d.
  DATA: empty_password        type bapipwd.
  DATA: password_length(4)    type c.

* ----- evaluate "login/password_downwards_compatibility"
  CALL FUNCTION 'GET_PASSWORD_COMPATIBILITY'
      IMPORTING only_old_style = lv_pwd_old_style.
* ----- if the old style, limit the length for 'New password' to 8
    if lv_pwd_old_style is not initial.
      password_length = '8'.
    else.
      describe field empty_password output-length password_length.
    endif.


  write_content_begin_html( exporting content_js  = iv_javascript
                                      content_onload = 'MobileHtmChangePw()'
                                      content_onkeydown = me->co_event_do_change_password
                                      content_hiddenfields = iv_hidden_fields
                                      content_title = m_txt_title_change_password
                                      changing rv_html = rv_html ).

* --- screen content
  concatenate rv_html
     co_crlf `        <table cellspacing="0" cellpadding="0" border="0">`
  into rv_html.                                          "#EC NOTEXT

* --- messages
  write_message_html( changing rv_html = rv_html ).

  if m_change_pw_step = co_change_pw_change.
    concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` me->m_txt_label_user `:</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginBldTxt">` me->m_sap_user `</span></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` me->m_txt_label_password `</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="password" id="` me->co_password `" name="` me->co_password `" onfocus="focusIn(this)" onblur="focusOut(this)" size="12" maxlength="` password_length
`"/></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td colspan="2" class="MobileLoginTopCell"><span class="MobileLoginStdTxt">` text-007 `:</span></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` me->m_txt_label_password `</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="password" id="` me->co_password_new `" name="` me->co_password_new `" onfocus="focusIn(this)" onblur="focusOut(this)" size="12" maxlength="`
password_length `"/></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` text-006 `</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="password" id="` me->co_password_repeat `" name="` me->co_password_repeat `" onfocus="focusIn(this)" onblur="focusOut(this)" size="12" maxlength="`
password_length `"/></td>`
     co_crlf `            </tr>`
    into rv_html.                                           "#EC NOTEXT
  endif.

  concatenate rv_html
     co_crlf `            <tr>`
    into rv_html.                                           "#EC NOTEXT

  if m_change_pw_step <> co_change_pw_was_changed.
    if m_change_pw_step = co_change_pw_change.
      concatenate rv_html
        co_crlf `              <td class="MobileLoginBtnCell">`
        co_crlf `              <input class="MobileLoginStdBtn" type="button" value=" ` me->m_txt_button_change_passwd `" onclick="` me->co_its_js_submit_changepwd `('` me->co_event_do_change_password `'); return false;"></td>`
      into rv_html.                                         "#EC NOTEXT
    endif.
    if m_change_pw_step = co_change_pw_change and m_change_pw_can_cancel = 'X'.
      concatenate rv_html
        co_crlf `              <td class="MobileLoginBtnCell"><input class="MobileLoginStdBtn" type="button" value="` me->m_txt_button_cancel `" onclick="` me->co_its_js_submit_changepwd `('` me->co_event_cancel_password `'); return false;"></td>`
      into rv_html.                                         "#EC NOTEXT
    elseif m_change_pw_step = co_change_pw_not_possible.
      concatenate rv_html
        co_crlf `              <td class="MobileLoginBtnCell"><input class="MobileLoginStdBtn" type="button" value="` me->m_txt_button_cancel `" onclick="` me->co_its_js_submit_changepwd `('` me->co_event_cancel_password `'); return false;"></td>`
      into rv_html.                                         "#EC NOTEXT
    endif.
  elseif m_change_pw_step = co_change_pw_was_changed.
    concatenate rv_html
      co_crlf `              <td class="MobileLoginBtnCell"><input class="MobileLoginStdBtn" type="button" value="` me->m_txt_button_continue `" onclick="` me->co_its_js_submit_changepwd `('` me->co_event_continue_password `'); return false;"></td>`
    into rv_html.                                           "#EC NOTEXT
  endif.

  concatenate rv_html
     co_crlf `            </tr>`
     co_crlf `          </table>`
  into rv_html.

* --- content end
  write_content_end_html( changing rv_html = rv_html ).

endmethod.


method HTM_LOGIN.
*CALL METHOD SUPER->HTM_LOGIN
*  EXPORTING
*    IV_JAVASCRIPT    =
*    IV_HIDDEN_FIELDS =
*  RECEIVING
*    RV_HTML          =
*    .

  data: lv_value              type    string,
        lv_key                type    string,
        lv_favicon            type    string,
        lv_favicon_data       type    xstring.

* --- content begin / title
  write_content_begin_html( exporting content_js  = iv_javascript
                                      content_onload = 'MobileHtmLogin()'
                                      content_onkeydown = me->co_event_login
                                      content_hiddenfields = iv_hidden_fields
                                      content_title = m_txt_title_login
                            changing rv_html = rv_html ).

* --- screen content
  concatenate rv_html
     co_crlf `          <table cellspacing="0" cellpadding="0" border="0">`
  into rv_html.                                          "#EC NOTEXT

* --- messages
  write_message_html( changing rv_html = rv_html ).

* --- display sap system id ?
  if  c_login_params-sysid_visible is not initial.
    concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` m_txt_label_system `:</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="text" disabled="disabled" id="sysid" name="sysid" size="3" maxlength="3" value="` sy-sysid `"/></td>`
     co_crlf `            </tr>`
    into rv_html.
  endif.                                                 "#EC NOTEXT

* --- display client ?
  if  c_login_params-client_visible is not initial.
    concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` m_txt_label_client `:</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="text" `
    into rv_html.                                         "#EC NOTEXT

    if m_login_enabled is not initial.
       concatenate rv_html ` onfocus="focusIn(this)" onblur="focusOut(this)" ` into rv_html.      "#EC NOTEXT
    else.
       concatenate rv_html ` disabled="disabled" ` into rv_html.     "#EC NOTEXT
    endif.

    concatenate rv_html
     ` id="` co_sap_client `" name="` co_sap_client `" value="` m_sap_client `" size="3" maxlength="3"/></td>`
     `            </tr>`
    into rv_html.                                         "#EC NOTEXT
  endif.

  m_sap_user = CL_ABAP_DYN_PRG=>ESCAPE_XSS_XML_HTML( m_sap_user ).
  concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` m_txt_label_user `:</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="text" id="` me->co_sap_user `" name="` me->co_sap_user `" value="` m_sap_user `" `
     ` onfocus="focusIn(this)" onblur="focusOut(this)" size="12" maxlength="12"/></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` m_txt_label_password `:</span><span class="MobileLoginRedTxt">*</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><input class="MobileLoginStdEdt" type="password" id="` me->co_sap_password `" name="` me->co_sap_password `" onfocus="focusIn(this)" onblur="focusOut(this)" size="12" maxlength="40"/></td>`
     co_crlf `            </tr>`
  into rv_html.                                             "#EC NOTEXT

* --- display language ?
if  c_login_params-langu_visible is not initial.
    concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginStdCell"><span class="MobileLoginStdTxt">` m_txt_label_language `:</span></td>`
     co_crlf `              <td class="MobileLoginStdCell"><select class="MobileLoginStdEdt" id= "` co_sap_language `" name="` co_sap_language `" size="1">`
    into rv_html.                                           "#EC NOTEXT

    if m_login_enabled is initial.
       concatenate rv_html ` disabled="disabled" ` into rv_html.        "#EC NOTEXT
    endif.

    field-symbols: <l> like line of  m_languages.
    loop at  m_languages assigning <l>.
       lv_value = <l>-value.
       lv_key   = <l>-name.
       concatenate rv_html ` <option ` into rv_html.           "#EC NOTEXT
       if lv_key eq m_language.
          concatenate rv_html ` selected ` into rv_html.       "#EC NOTEXT
       endif.
       concatenate rv_html ` value="` lv_key `">` lv_value `</option>` into rv_html.     "#EC NOTEXT
     endloop.

     concatenate rv_html
     co_crlf `              </select> </td>`
     co_crlf `            </tr>`
     into rv_html.                                           "#EC NOTEXT
endif.

* --- display accessibility, not supported.

* --- display login button, change password
  concatenate rv_html
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginTopCell">&nbsp</td>`
     co_crlf `              <td class="MobileLoginTopCell"><input class="MobileLoginStdBtn" type="button" value="` me->m_txt_button_login `" onclick="` me->co_its_js_submit_login `('` me->co_event_login `'); return false;"></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginTopCell" colspan=2><a href="#" onclick="` me->co_its_js_submit_login `('` me->co_event_change_password `'); return false;">` me->m_txt_title_change_password
`</a></td>`
     co_crlf `            </tr>`
     co_crlf `          </table>`
  into rv_html.                                             "#EC NOTEXT

* --- content end
  write_content_end_html( changing rv_html = rv_html ).

endmethod.


method HTM_MESSAGE_BOX.

* --- content begin / title
  write_content_begin_html( exporting content_js  = iv_javascript
                                      content_onload = ''
                                      content_onkeydown = me->co_event_continue_password
                                      content_hiddenfields = iv_hidden_fields
                                      content_title = me->m_txt_title_login
                                      changing rv_html = rv_html ).

* screen content
  concatenate rv_html
     co_crlf `          <table cellspacing="0" cellpadding="0" border="0">`
  into rv_html.                                          "#EC NOTEXT

* --- messages
  write_message_html( changing rv_html = rv_html ).

* --- display login button, change password
  concatenate rv_html
     co_crlf `         <tr>`
     co_crlf `           <td class="MobileLoginStdCell">`
     co_crlf `             <input class="MobileLoginStdBtn" type="button" value="` m_txt_button_continue `" onclick="` me->co_its_js_submit_continue `('` me->co_event_continue_password `'); return false;"></td>`
     co_crlf  `        </tr>`
     co_crlf `         </table>`
  into rv_html.                                             "#EC NOTEXT

* --- content end
  write_content_end_html( changing rv_html = rv_html ).

endmethod.


method HTM_SESSION_QUERY.

  data: messages_control      type ref to object.
  data: lt_userlist           type table of uinfo,
        ls_user               like line of lt_userlist,
        lv_string             type string,
        lv_timval             type t,
        lv_tempchar(40)       type c,
        lv_time_offset        type syuzeit.

  include tskhincl.

* --- content begin / title
  write_content_begin_html( exporting content_js  = iv_javascript
                                      content_onload = ''
                                      content_onkeydown = me->co_event_session_query
                                      content_hiddenfields = iv_hidden_fields
                                      content_title = me->m_txt_session_title
                                      changing rv_html = rv_html ).

* --- screen content
  concatenate rv_html
     co_crlf `          <table cellspacing="0" cellpadding="0" border="0">`
  into rv_html.                                          "#EC NOTEXT

* --- messages
  write_message_html( changing rv_html = rv_html ).

* --- open sessions
  concatenate rv_html
     co_crlf `      <tr>`
     co_crlf `        <td colspan="2" align="center">`
     co_crlf `          <table class="MobileLoginScreen" cellspacing="0" cellpadding="3" border="1">`
     co_crlf `            <tr>`
                            `<td colspan="3" class="MobileLoginTitle"><span class="MobileLoginBldTxt">` text-005 `</span></td>`
                         `</tr>`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginSubTitle"><span class="MobileLoginStdTxt">` text-001 `</span></td>`
     co_crlf `              <td class="MobileLoginSubTitle"><span class="MobileLoginStdTxt">` text-002 `</span></td>`
     co_crlf `              <td class="MobileLoginSubTitleE"><span class="MobileLoginStdTxt">` text-004 `</span></td>`
     co_crlf `            </tr>`
  into rv_html.                                             "#EC NOTEXT

*  call function 'TH_USER_LIST'
*    tables
*      list = lt_userlist.
*
* ------ Avoid sessions which were created by logon application
* ------ This is just the display case, the session list for deleting sessions is created
* ------ in get_sessions_to_delete() and specifies a offset of 30 seconds, so it does not
* ------ make any sense to shorten this 30 seconds offset here.
*  lv_time_offset = sy-uzeit - 30.
*  loop at lt_userlist into ls_user where bname = sy-uname
*                                     and mandt = sy-mandt
*                                     and zeit < lv_time_offset
*                                     and ( protocol = th_plugin_protocol_http
*                                     or protocol = th_plugin_protocol_https ).
  lt_userlist = get_sessions_to_delete( ).
  loop at lt_userlist into ls_user.
    move ls_user-zeit to lv_timval.
    write lv_timval to lv_tempchar using edit mask '__:__:__'."#EC NOTEXT
    move lv_tempchar(8) to lv_string.

    concatenate rv_html
       co_crlf `      <tr>`
       co_crlf `        <td class="MobileLoginSpcCell">`
       co_crlf `          <span class="MobileLoginStdTxt">` ls_user-mandt `</span>`
       co_crlf `        </td>`
       co_crlf `        <td class="MobileLoginSpcCell">`
       co_crlf `          <span class="MobileLoginStdTxt">` ls_user-bname `</span>`
       co_crlf `        </td>`
       co_crlf `        <td class="MobileLoginSpcCell">`
       co_crlf `          <span class="MobileLoginStdTxt">` lv_string `</span>`
       co_crlf `        </td>`
       co_crlf `      </tr>`
    into rv_html.                                             "#EC NOTEXT
  endloop.

  concatenate rv_html
     co_crlf `          </table>`
     co_crlf `        </td>`
     co_crlf `      </tr>`
  into rv_html.                                               "#EC NOTEXT

* --- checkbox
  concatenate rv_html
     co_crlf `<tr>`
       `<td class="MobileLoginTopCell">`
        `<input type="checkbox" class="MobileLoginCheck" `
          `name="` co_cbx_delete_session `" id="` co_cbx_delete_session `" `
     into rv_html.                                            "#EC NOTEXT

  if m_session_delete_possible NE SPACE.
    concatenate rv_html ` checked="checked" value="X"> </td> ` into rv_html.  "#EC NOTEXT
  else.
    concatenate rv_html ` disabled="disabled" value="X"> </td> ` into rv_html. "#EC NOTEXT
  endif.

  concatenate rv_html
       `<td class="MobileLoginTopCell"><label for="` co_cbx_delete_session `" class="MobileLoginStdTxt">` m_txt_delete_session `</label>`
       `</td>`
     co_crlf  `</tr>`
     into rv_html.                                                    "#EC NOTEXT

  concatenate rv_html
     co_crlf `      <tr>`
     co_crlf `        <td colspan="2" class="MobileLoginTopCell"><input type="button" class="MobileLoginStdBtn" value="` m_txt_button_continue `" onclick="` me->co_its_js_submit_querysess `('` me->co_event_session_query `'); return false;">`
     co_crlf `        </td>`
     co_crlf `      </tr>`
     co_crlf `    </table>`
  into rv_html.                                             "#EC NOTEXT

* --- content end
  write_content_end_html( changing rv_html = rv_html ).

endmethod.


method HTM_SYSTEM_MESSAGE.
  data:
         lv_count              like sy-index,               "#EC NEEDED
         lv_last_msg           type temsg-id.

  data temsgs type t_temsg_tab.
  data temsg type temsg.
  data messages type t_sys_message_tab.
  data message  type t_sys_message.

  include tskhincl.
  include lsm02def.

* --- Get last message id that was dispalyed to user
  call function 'SM02_GET_LAST_USREMSG_ID'
    exporting
      entry_type    = call_from_dynp
    importing
      last_usr_emsg = lv_last_msg.

  call function 'SM02_GET_UNREAD_MESSAGE'
    exporting
      entry_type    = call_from_dynp
      last_usr_emsg = lv_last_msg
    importing
      count         = lv_count
    tables
      messages      = temsgs.

  sort temsgs by id descending.
  read table temsgs index 1 into temsg.
  if sy-subrc <> 0.
    return.
  endif.

* --- set the new last dispalyed message for the user
  call function 'SM02_SET_LAST_USREMSG_ID'
    exporting
      last_usr_emsg = temsg-id.

  messages = format_system_messages( temsgs ).

* --- content begin / title
  write_content_begin_html( exporting content_js  = iv_javascript
                                      content_onload = ''
                                      content_onkeydown = me->co_event_continue_sys_message
                                      content_hiddenfields = iv_hidden_fields
                                      content_title = me->m_txt_title_system_msg
                                      changing rv_html = rv_html ).

* --- screen content
  concatenate rv_html
     co_crlf `        <table class="MobileLoginSubScreen" cellspacing="0" cellpadding="0" border="0" >`
  into rv_html.                                          "#EC NOTEXT

* --- insert messages into html output
  loop at messages into message.
      concatenate rv_html
        co_crlf `      <tr>`
        co_crlf `        <td class="MobileLoginMsgCell">`
        co_crlf `          <span class="MobileLoginBldTxt">` me->m_txt_col_sysmsg_id `:&nbsp</span>`
        co_crlf `          <span class="MobileLoginStdTxt">` message-id `&nbsp</span>`
        co_crlf `          <span class="MobileLoginBldTxt">` me->m_txt_col_sysmsg_author `:&nbsp</span>`
        co_crlf `          <span class="MobileLoginStdTxt">` message-author `</span>`
        co_crlf `        </td>`
        co_crlf `      </tr>`
        co_crlf `      <tr>`
        co_crlf `        <td class="MobileLoginMsgCellE">`
        co_crlf `          <p class="MobileLoginMsgTxt">`  message-html `</p>`
        co_crlf `        </td>`
        co_crlf `      </tr>`
        co_crlf `      <tr>`
        co_crlf `        <td class="MobileLoginStdCell"><hr class="MobileLoginUdrLine"></td>`
        co_crlf `      </tr>`
     into rv_html.                                          "#EC NOTEXT
  endloop.

* --- continue button
  concatenate rv_html
     co_crlf `         <tr>`
     co_crlf `           <td colspan="2" class="MobileLoginStdCell">`
     co_crlf `             <input class="MobileLoginStdBtn" type="button" value="` m_txt_button_continue `" onclick="` me->co_its_js_submit_continue `('` me->co_event_continue_sys_message `'); return false;"></td>`
     co_crlf `         </tr>`
     co_crlf `       </table>`
  into rv_html.                                             "#EC NOTEXT

* --- content end
  write_content_end_html( changing rv_html = rv_html ).

endmethod.


method WRITE_CONTENT_BEGIN_HTML.

data:  lv_css_style          type    string.

* --- get css style sheet
  lv_css_style = write_css_style( ).

* --- begin html
  concatenate
     `<html>`
     co_crlf `  <head>`
     co_crlf `    <title>ITSmobile login</title>`
     co_crlf `    <meta http-equiv="OnKey0x0D" content="javascript:MobileSubmitLogin('` content_onkeydown `')">`
     co_crlf `    <meta http-equiv="IBrowse_OnKey0x0D" content="javascript:MobileSubmitLogin('` content_onkeydown `')">`
     co_crlf `    <style type="text/css">`
             lv_css_style
     co_crlf `    </style>`
     co_crlf `    <script language="JavaScript" type="text/javascript">`           "#EC NOTEXT
             content_js
     co_crlf `    </script>`
     co_crlf `  </head>`
     co_crlf `  <body class="MobileLoginBody" `
  into rv_html.                                             "#EC NOTEXT

* --- onload
  if content_onload is not initial.
      concatenate rv_html
        `onload="` content_onload `" `
      into rv_html.                                             "#EC NOTEXT
  endif.

* --- onkeydown
  if content_onkeydown is not initial.
      concatenate rv_html
        `onkeydown="return MobileKeyEvent(event, '` content_onkeydown `');" `
      into rv_html.                                             "#EC NOTEXT
  endif.

  concatenate rv_html `>` into rv_html.                                             "#EC NOTEXT

  concatenate rv_html
     co_crlf `  <form name="` me->co_its_form_login `" action="` me->m_sap_application `" method="post">`
            content_hiddenfields
  into rv_html.                                             "#EC NOTEXT

* --- content begin
  concatenate rv_html
     co_crlf `    <table class="MobileScreen" cellspacing="0" cellpadding="0" border="0">`
     co_crlf `      <tr>`
     co_crlf `        <td align="center">`
     co_crlf `          <table class="MobileLoginScreen" cellspacing="0" cellpadding="0" border="0">`
     co_crlf `            <tr>`
     co_crlf `              <td class="MobileLoginTitle"><span class="MobileLoginBldTxt">` content_title `</span></td>`
     co_crlf `            </tr>`
     co_crlf `            <tr style="height:2px">`
     co_crlf `              <td class="MobileLoginContent">`
     into rv_html.                                          "#EC NOTEXT

endmethod.


method WRITE_CONTENT_END_HTML.

  concatenate rv_html
     co_crlf `              </td>`
     co_crlf `            </tr>`
     co_crlf `          </table>`
     co_crlf `        </td>`
     co_crlf `      </tr>`
     co_crlf `    </table>`
     co_crlf `   </form>`
     co_crlf `  </body>`
     co_crlf `</html>`
  into rv_html.                                             "#EC NOTEXT

endmethod.


method WRITE_CSS_STYLE.
*CALL METHOD SUPER->WRITE_JS_FUNCTIONS
*  RECEIVING
*    RV_CSS_STYLE =
*
  LOG__METHOD( name = 'cl_its_mobile_login=>write_css_style' ).     "#EC NOTEXT

  concatenate rv_css_style
    co_crlf `      a:link     { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#204ba2;font-weight:normal;text-decoration:none;}`
    co_crlf `      a:visited  { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#204ba2;font-weight:normal;text-decoration:none;}`
    co_crlf `      a:hover    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#FF7800;font-weight:normal;}`
    co_crlf `      .MobileLoginBody      { background-color:#EBEFF2; width:100%; height:100%; margin: 0px; padding: 0px; border-width: 0px; }`
    co_crlf `      .MobileScreen         { width:100%; height:100%;padding:0px; margin:0px; border:0px; }`
    co_crlf `      .MobileLoginScreen    { background-color:#FFFFFF; width:100% height:100%; padding:0px; margin:0px; border:0px; }`
    co_crlf `      .MobileLoginTitle     { background-color:#B6CFE6;border-width:0 0 1px 0;border-style:none none solid none;border-color:#F2F2F2;color:#000;padding:3px 5px 3px 6px;height:100%}`
    co_crlf `      .MobileLoginSubScreen { background-color:#FFFFFF; width:100%; padding:0px; margin:0px; border:0px; }`
    co_crlf `      .MobileLoginSubTitle  { background-color:#B5B2B5;border-width:0 1px 1px 0;border-style:none solid solid none;border-color:#F2F2F2;color:#000;padding:3px 5px 3px 6px;height:100%}`
    co_crlf `      .MobileLoginSubTitleE { background-color:#B5B2B5;border-width:0 0px 1px 0;border-style:none none solid none;border-color:#F2F2F2;color:#000;padding:3px 5px 3px 6px;height:100%}`
    co_crlf `      .MobileLoginContent   { background-color:#FFF;border-color:#B6CFE6;border-style:solid;border-width:1px; padding: 7px 7px 7px 7px;}`
    co_crlf `      .MobileLoginStdTxt    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:normal}`
    co_crlf `      .MobileLoginMsgTxt    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:normal;line-height:1.0em;}`
    co_crlf `      .MobileLoginBldTxt    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:bold}`
    co_crlf `      .MobileLoginRedTxt    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:red;font-weight:bold}`
    co_crlf `      .MobileLoginStdCell   { padding:0px 5px 0px 0px; }`
    co_crlf `      .MobileLoginTopCell   { padding:7px 5px 0px 0px; }`
    co_crlf `      .MobileLoginSpcCell   { padding:0px 5px 0px 6px; }`
    co_crlf `      .MobileLoginBtnCell   { padding:0px 5px 0px 0px; }`
    co_crlf `      .MobileLoginMsgCell   { background-color:#B5B2B5;color:#000;padding:2px 5px 2px 6px;}`
    co_crlf `      .MobileLoginMsgCellE  { background-color:#FFFFFF;color:#000;padding:3px 5px 0px 6px; spacing:0px}`
    co_crlf `      .MobileLoginUdrLine   { size:2px;color:#306898;margin-top:2px;margin-bottom:2px;}`
    co_crlf `      .MobileLoginCheck     { }`
    co_crlf `      .MobileLoginStdEdt    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:normal}`
    co_crlf `      .MobileLoginStdBtn    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:normal}`
    co_crlf `      .MobileLoginStdBtn    { font-family:Arial,Helvetica,sans-serif;font-size:400%;font-style:normal;color:#000;font-weight:normal}`
  into rv_css_style.                                          "#EC NOTEXT

  LOG__END_METHOD( ).

endmethod.


method WRITE_JS_FUNCTIONS.
*CALL METHOD SUPER->WRITE_JS_FUNCTIONS
*  RECEIVING
*    RV_JSCRIPT =
*
  LOG__METHOD( name = 'cl_its_mobile_login=>write_js_functions' ).     "#EC NOTEXT

  data functions type t_js_function_stab.
  field-symbols <function> type t_js_function.

  concatenate rv_jscript
    co_crlf `/* ------------------------------------------- */`
    co_crlf `/* javascript for ITSmobile services          */`
    co_crlf `/* ------------------------------------------- */`
    co_crlf `/* global focus field */`
    co_crlf `var g_MobileFocusElement = null;`
    co_crlf `var g_MobileFirstSend = true;`
    co_crlf ``
    co_crlf `function setMobileFocus(el)`
    co_crlf `{`
    co_crlf `   /* check against multiple send to WebAs */`
    co_crlf `   g_MobileFocusElement = el;`
    co_crlf `   setTimeout("g_MobileFocusElement.focus()", 50);`
    co_crlf `}`
    co_crlf ``
    co_crlf `function firstSend()`
    co_crlf `{`
    co_crlf `   /* Some industrial browsers have problems submitting a form`
    co_crlf `    * when software keyboard is open, therefor remove the focus`
    co_crlf `    * from input field. */`
    co_crlf `   window.focus();`
    co_crlf ``
    co_crlf `   if ( !g_MobileFirstSend )`
    co_crlf `     return false;`
    co_crlf ``
    co_crlf `   /* remember first send is done */`
    co_crlf `   g_MobileFirstSend = false;`
    co_crlf ``
    co_crlf `   /* re-enable the submit after 3 seconds */`
    co_crlf `   setTimeout("g_MobileFirstSend = true", 3000);`
    co_crlf ``
    co_crlf `   /* this is the first send */`
    co_crlf `   return true;`
    co_crlf `}`
    co_crlf ``
    co_crlf `function submitOnce()`
    co_crlf `{`
    co_crlf `   /* check against multiple send to WebAs */`
    co_crlf `   if ( firstSend() )`
    co_crlf `   {`
    co_crlf `      /* submit once to WebAs */`
    co_crlf `      document.MobileLoginForm.submit();`
    co_crlf `   }`
    co_crlf `}`
    co_crlf ``
    co_crlf `function setActionAndSubmit(action)`
    co_crlf `{`
    co_crlf `   /* check if login fields are filled */`
    co_crlf `   if ( ( ( action == 'onLogin' || action == 'onChangePwd' ) && MobileHtmLogin() ) ||`
    co_crlf `        ( action == 'onDoChangePwd' && MobileHtmChangePw() ) )`
    co_crlf `   {`
    co_crlf `      /* not all fields filled, do not submit */`
    co_crlf `      return false;`
    co_crlf `   }`
    co_crlf ``
    co_crlf `   if ( action == 'onDoChangePwd' )`
    co_crlf `   {`
    co_crlf `      var sap_pwd = document.MobileLoginForm.elements["sap-password"];`
    co_crlf `      if (sap_pwd != null)`
    co_crlf `         sap_pwd.value = document.MobileLoginForm.elements["sap-system-login-password"].value;`
    co_crlf `   }`
    co_crlf ``
    co_crlf `   /* set action type ( query session ) */`
    co_crlf `   document.MobileLoginForm.elements["sap-system-login-oninputprocessing"].value=action;`
    co_crlf ``
    co_crlf `   /* submit once to WebAs */`
    co_crlf `   submitOnce();`
    co_crlf `   return true;`
    co_crlf `}`
    co_crlf ``
  into rv_jscript.                                          "#EC NOTEXT

  concatenate rv_jscript
    co_crlf `/* --- SUBMIT LOGIN ---------------------------*/`
    co_crlf `function MobileSubmitLogin(value)`
    co_crlf `{`
    co_crlf `  setActionAndSubmit(value);`
    co_crlf `}`
    co_crlf ``
    co_crlf `/* --- SUBMIT QUERY SESSIONS -------------*/`
    co_crlf `function MobileSubmitQuerySession(value)`
    co_crlf `{`
    co_crlf `  setActionAndSubmit(value);`
    co_crlf `}`
    co_crlf ``
    co_crlf `/* --- SUBMIT PASSWORD CHANGED -----------*/`
    co_crlf `function MobileSubmitChangePwd(value)`
    co_crlf `{`
    co_crlf `  setActionAndSubmit(value);`
    co_crlf `}`
    co_crlf ``
    co_crlf `/* --- SUBMIT CONTINUE -----------*/`
    co_crlf `function MobileSubmitContinue(value)`
    co_crlf `{`
    co_crlf `  setActionAndSubmit(value);`
    co_crlf `}`
    co_crlf ``
  into rv_jscript.                                          "#EC NOTEXT

  concatenate rv_jscript
    co_crlf `/* --- ONKEYDOWN FUNCTIONS --------------------*/`
    co_crlf `function MobileKeyEvent(myevent, action)`
    co_crlf `{`
    co_crlf `  if (myevent.keyCode == 13)`
    co_crlf `  {`
    co_crlf `    if (setActionAndSubmit(action) == true)`
    co_crlf `    {`
    co_crlf `      /* stop event bubbling */`
    co_crlf `      myevent.cancelBubble = true;`
    co_crlf `      myevent.returnValue = false;`
    co_crlf `      myevent.keyCode = 0;`
    co_crlf `      return false;`
    co_crlf `    }`
    co_crlf `  }`
    co_crlf ``
    co_crlf `  return true;`
    co_crlf `}`
    co_crlf ``
  into rv_jscript.                                          "#EC NOTEXT

  concatenate rv_jscript
    co_crlf `/* --- ONLOAD FUNCTIONS------------------------*/`
    co_crlf `function MobileHtmLogin()`
    co_crlf `{`
    co_crlf `  /* returns false if there are no more empty fields on the screen */`
    co_crlf `  return ( jumpTo("` me->co_sap_client `") || jumpTo("` me->co_sap_user `") || jumpTo("` me->co_sap_password `") );`
    co_crlf `}`
    co_crlf ``
    co_crlf `function MobileHtmChangePw()`
    co_crlf `{`
    co_crlf `  /* returns false if there are no more empty fields on the screen */`
    co_crlf `  return ( jumpTo("` me->co_password `") || jumpTo("` me->co_password_new `") || jumpTo("` me->co_password_repeat `") );`
    co_crlf `}`
    co_crlf ``
  into rv_jscript.                                          "#EC NOTEXT

  concatenate rv_jscript
    co_crlf `function jumpTo(name)`
    co_crlf `{`
    co_crlf `  var el = document.MobileLoginForm.elements[name];`
    co_crlf `  if (el != null && !el.disabled && el.value == "")`
    co_crlf `  {`
    co_crlf `     setMobileFocus(el);`
    co_crlf `     return true;`
    co_crlf `  }`
    co_crlf `  return false;`
    co_crlf `}`
    co_crlf ``
    co_crlf `function focusIn(el)`
    co_crlf `{`
    co_crlf `  if (el != null && !el.disabled)`
    co_crlf `    el.style.backgroundColor = "#FFF09E";`
    co_crlf `}`
    co_crlf ``
    co_crlf `function focusOut(el)`
    co_crlf `{`
    co_crlf `  if (el != null && !el.disabled)`
    co_crlf `    el.style.backgroundColor = "";`
    co_crlf `}`
    co_crlf ``
  into rv_jscript.                                          "#EC NOTEXT

* Overdefinable JS Functions
  write_js_html_functions( changing functions = functions ).

  loop at functions assigning <function>.
    concatenate
      rv_jscript
      co_crlf <function>-js
    into rv_jscript.                                        "#EC NOTEXT
  endloop.

*Note 2028904 - Start                                      1
  clear: functions, functions[].
  DATA: custom_script type STRING.
  custom_script = WRITE_CUSTOM_JS( ).
  if custom_script is not initial.
    concatenate rv_jscript
        co_crlf
        custom_script
        into rv_jscript.
  endif.
*Note 2028904 - End

  LOG__END_METHOD( ).

endmethod.


method WRITE_JS_HTML_FUNCTIONS.
*CALL METHOD SUPER->WRITE_JS_HTML_FUNCTIONS
*  CHANGING
*    FUNCTIONS =
*    .
endmethod.


method WRITE_MESSAGE_HTML.
  data: lv_msg_item           type    bspmsg.

* --- loop over the messages
  if me->m_logmessages is not initial.

    loop at me->m_logmessages into lv_msg_item.
      concatenate rv_html
        co_crlf `  <tr>`
        co_crlf `    <td colspan="2" class="MobileLoginStdCell"><span class="MobileLoginStdTxt">`  lv_msg_item-message `</span></td>`
        co_crlf `  </tr>`
        co_crlf `  <tr>`
        co_crlf `    <td colspan="2" class="MobileLoginStdCell"><hr class="MobileLoginUdrLine"></td>`
        co_crlf `  </tr>`
     into rv_html.                                       "#EC NOTEXT
    endloop.

  endif.

endmethod.
ENDCLASS.
