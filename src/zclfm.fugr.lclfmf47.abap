*---------------------------------------------------------------------*
*       FORM CHECK_CHANGE_NUMBER_USAGE                                *
*---------------------------------------------------------------------*
*  Chcks whether object is already classified with another
*  change number to the same date.
*  Tables to check: kssk, ausp
*
*  -> p_object    : object
*  -> p_classtype : class type
*  -> p_new_cn    : change number to check
*  -> p_date      : date of change number
*
*  <- p_ret     : 0  change number can be used
*                 1  check not possible
*  <- p_used_cn : change number already used to same date
*
*---------------------------------------------------------------------*

form check_change_number_usage
     using    p_object
              p_classtype
              p_table
              p_multobj
              p_new_cn
              p_date_of_change
     changing p_ret
              p_used_cn.

  data: l_object  like kssk-objek,
        l_inobj   like inob-cuobj,
        l_used_cn like rmclf-aennr1.

  p_ret = 1.
  check p_new_cn  <> space.
  check p_classtype <> space.

  if p_multobj is initial.
    l_object = p_object.
  else.
    call function 'CUOB_GET_NUMBER'
         exporting
              class_type       = p_classtype
              object_id        = p_object
              table            = p_table
         importing
              object_number    = l_inobj
         exceptions
              lock_problem     = 01
              object_not_found = 02.
    if sy-subrc > 0.
      exit.
    endif.
    l_object = l_inobj.
  endif.

  select aennr from kssk up to 1 rows into l_used_cn
         where objek = l_object
           and klart = p_classtype
           and datuv = p_date_of_change
           and aennr <> p_new_cn.
  endselect.

  if syst-subrc > 0.
*   no entry in kssk with same date
    select aennr from ausp up to 1 rows into l_used_cn
           where objek = l_object
             and klart = p_classtype
             and datuv = p_date_of_change
             and aennr <> p_new_cn.
    endselect.
  endif.

  p_ret = 0.
  p_used_cn = l_used_cn.

endform.                               " CHECK_CHANGE_NUMBER_USAGE
