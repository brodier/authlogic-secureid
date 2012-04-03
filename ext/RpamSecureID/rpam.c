/******************************************************************************
 *
 * Rpam Copyright (c) 2008 Andre Osti de Moura <andreoandre@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * A full copy of the GNU license is provided in the file LICENSE.
 *
*******************************************************************************/
#include "ruby.h"
#include <security/pam_appl.h>

typedef struct {
	char *name;
  char *passcode;
} rpam_t;
    
static const char
*rpam_servicename = "rpam";

VALUE Rpam;

void Init_rpam();

/*
 * auth_pam_talker: supply authentication information to PAM when asked
 *
 * Assumptions:
 *   messages received from pam should correspond to messages provide to authpam
 *
 */
static
int auth_pam_talker(int num_msg,
				const struct pam_message ** msg,
				struct pam_response ** resp,
				void *appdata_ptr)
{

   	unsigned short i = 0;
	rpam_t *app_info = (rpam_t *) appdata_ptr;
	struct pam_response *response = 0;
  printf("\n DEBUG : Start pam talker \n");
  /* parameter sanity checking */
  if (!resp || !msg || !app_info)
      return PAM_CONV_ERR;
  if(num_msg != 1)
    return PAM_CONV_ERR;
  
  /* allocate memory to store response */
	response = malloc(sizeof(struct pam_response));
	if (!response)
		return PAM_CONV_ERR;
  /* initialize to safe values */
	response[0].resp_retcode = 0;
  response[0].resp = strdup(app_info->passcode);

	/* everything okay, set PAM response values */
	*resp = response;
	return PAM_SUCCESS;
}

/* Authenticates a user and returns TRUE on success, FALSE on failure
   username is pam login, num_msg is the size of msg_ary and rply_ary.
   msg_ary is the arry provide by call to method_pamconvmsg
   and rply_ary containt elements used to reply to pam messages */
VALUE method_authpam(VALUE self, VALUE username, VALUE pam_passcode) {	
  rpam_t app_info = {NULL, NULL};
	struct pam_conv conv_info = {&auth_pam_talker, (void *) &app_info};
	pam_handle_t *pamh = NULL;
	int result,i;
  app_info.name = STR2CSTR(username);
  app_info.passcode = STR2CSTR(pam_passcode);
 
	if ((result = pam_start(rpam_servicename, app_info.name, &conv_info, &pamh)) 
            != PAM_SUCCESS) {
        return Qfalse;
  }
  
  if ((result = pam_authenticate(pamh, PAM_DISALLOW_NULL_AUTHTOK))
         !=  PAM_SUCCESS) {
      printf("DEBUG : error in pam_authenticate result = %d\n",result);
      pam_end(pamh, PAM_SUCCESS); 
      return Qfalse;
  }
  printf("DEBUG : PAM Authenticate success\n");
  pam_end(pamh, PAM_SUCCESS);
  return Qtrue;
}

/* initialize */
void Init_rpam_secureid() {
	Rpam = rb_define_module("RpamSecureID");
  rb_define_method(Rpam, "auth_secureid", method_authpam, 2);	
}
