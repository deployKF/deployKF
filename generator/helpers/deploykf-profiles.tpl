## NOTE: we reference these templates in `./templates/.gomplateignore_template` and write the results to the `runtime`
##       directory to avoid re-evaluating them each time we need them (because they are computationally expensive)

##
## A JSON object for looking up users by id: {"<user_id>": <user_object>}
## - USAGE: `$users_id_mapping_json := tmpl.Exec "deploykf_profiles.users_id_mapping_json" .`
## - RUNTIME: `$users_id_mapping_json := tmpl.Exec "runtime/deploykf_profiles__users_id_mapping_json"`
##
{{<- define "deploykf_profiles.users_id_mapping_json" ->}}
{{<- $users_id_mapping := dict ->}}
{{<- $found_emails := dict ->}}
{{<- range $index, $user := .Values.deploykf_core.deploykf_profiles_generator.users ->}}
  {{<- if index $user "id" ->}}
    {{<- if has $users_id_mapping $user.id ->}}
      {{<- fail (printf "elements of `users` must have unique `id`, but '%s' appears more than once" $user.id) ->}}
    {{<- end ->}}

    {{<- /* verify this user's `email` */ ->}}
    {{<- if not (index $user "email") ->}}
      {{<- fail (printf "elements of `users` must have non-empty `email`, but element %d (user id: '%s') does not" $index $user.id) ->}}
    {{<- end ->}}

    {{<- /* cast `email` to lowercase, if applicable */ ->}}
    {{<- if $.Values.deploykf_core.deploykf_istio_gateway.gateway.emailToLowercase ->}}
      {{<- $user = coll.Merge (dict "email" ($user.email | toLower)) $user ->}}
    {{<- end ->}}

    {{<- /* verify this user's `email` is unique */ ->}}
    {{<- if has $found_emails $user.email ->}}
      {{<- fail (printf "elements of `users` must have unique `email`, but '%s' appears more than once" $user.email) ->}}
    {{<- end ->}}
    {{<- $found_emails = coll.Merge (dict $user.email true) $found_emails ->}}

    {{<- /* store in users_id_mapping */ ->}}
    {{<- $users_id_mapping = coll.Merge (dict $user.id $user) $users_id_mapping ->}}
  {{<- else ->}}
    {{<- fail (printf "elements of `users` must have non-empty `id`, but element %d does not" $index) ->}}
  {{<- end ->}}
{{<- end ->}}
{{<- $users_id_mapping | data.ToJSON ->}}
{{<- end ->}}

##
## A JSON object for looking up groups by id: {"<group_id>": {"<user_id>": <user_object>}}
## - USAGE: `$groups_id_mapping_json := tmpl.Exec "deploykf_profiles.groups_id_mapping_json" (dict "Values" .Values "users_id_mapping" $users_id_mapping)`
## - RUNTIME: `$groups_id_mapping_json := tmpl.Exec "runtime/deploykf_profiles__groups_id_mapping_json"`
##
{{<- define "deploykf_profiles.groups_id_mapping_json" ->}}
{{<- $users_id_mapping := .users_id_mapping ->}}
{{<- $groups_id_mapping := dict ->}}
{{<- range $group_index, $group := .Values.deploykf_core.deploykf_profiles_generator.groups ->}}
  {{<- if index $group "id" ->}}
    {{<- if has $groups_id_mapping $group.id ->}}
      {{<- fail (printf "elements of `groups` must have unique `id`, but '%s' appears more than once" $group.id) ->}}
    {{<- end ->}}

    {{<- /* get the user objects for each user in this group */ ->}}
    {{<- $group_users := dict ->}}
    {{< range $group_user_index, $group_user_id := index $group "users" | default coll.Slice | uniq ->}}
      {{<- if has $users_id_mapping $group_user_id ->}}
        {{<- $group_user := index $users_id_mapping $group_user_id ->}}
        {{<- $group_users = coll.Merge (dict $group_user_id $group_user) $group_users ->}}
      {{<- else ->}}
        {{<- fail (printf "elements of `groups[%d].users` (group id: '%s') may only reference user IDs that exist in `users`, but element %d references '%s' which does not exist" $group_index $group.id $group_user_index $group_user_id) ->}}
      {{<- end ->}}
    {{<- end ->}}

    {{<- /* store in groups_id_mapping */ ->}}
    {{<- $groups_id_mapping = coll.Merge (dict $group.id $group_users) $groups_id_mapping ->}}
  {{<- else ->}}
    {{<- fail (printf "elements of `groups` must have non-empty `id`, but element %d does not" $group_index) ->}}
  {{<- end ->}}
{{<- end ->}}
{{<- $groups_id_mapping | data.ToJSON ->}}
{{<- end ->}}

##
## A JSON object for looking up the users of each profile, and the associated access level: {"<profile_name>": {"<user_id>": <access_object>}}
## - USAGE: `$profiles_users_access_mapping_json := tmpl.Exec "deploykf_profiles.profiles_users_access_mapping_json" (dict "Values" .Values "users_id_mapping" $users_id_mapping "groups_id_mapping" $groups_id_mapping)`
## - RUNTIME: `$profiles_users_access_mapping_json := tmpl.Exec "runtime/deploykf_profiles__profiles_users_access_mapping_json"`
##
{{<- define "deploykf_profiles.profiles_users_access_mapping_json" ->}}
{{<- $users_id_mapping := .users_id_mapping ->}}
{{<- $groups_id_mapping := .groups_id_mapping ->}}
{{<- $profiles_users_access_mapping := dict ->}}
{{<- range $profile_index, $profile := .Values.deploykf_core.deploykf_profiles_generator.profiles ->}}
  {{<- if not (index $profile "name") ->}}
      {{<- fail (printf "elements of `profiles` must have non-empty `name`, but element %d does not" $profile_index) ->}}
  {{<- end ->}}

  {{<- $full_profile_name := printf "%s%s" $.Values.deploykf_core.deploykf_profiles_generator.profileDefaults.profileNamePrefix $profile.name ->}}

  {{<- $profile_ownerEmail := index $profile "ownerEmail" | default $.Values.deploykf_core.deploykf_profiles_generator.profileDefaults.ownerEmail ->}}

  {{<- if has $profiles_users_access_mapping $full_profile_name ->}}
    {{<- fail (printf "elements of `profiles` must have unique `name`, but '%s' appears more than once" $profile.name) ->}}
  {{<- end ->}}

  {{<- /* build a dictionary containing the access for each user: {"<user_id>": <access_object>} */ ->}}
  {{<- $user_access_mapping := dict ->}}
  {{<- range $member_index, $member := index $profile "members" | default coll.Slice ->}}
    {{<- $member_access := coll.Merge (index $member "access" | default dict) $.Values.deploykf_core.deploykf_profiles_generator.profileDefaults.memberAccess ->}}

    {{<- /* verify this member's `access.role` */ ->}}
    {{<- if not ($member_access.role | has (coll.Slice "view" "edit")) ->}}
      {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may only set `role` to 'view' or 'edit', but element %d sets '%s'" $profile_index $profile.name $member_index $member_access.role) ->}}
    {{<- end ->}}

    {{<- /* verify this member's `access.notebooksAccess` */ ->}}
    {{<- if not ($member_access.notebooksAccess | test.IsKind "bool") ->}}
      {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may only set `notebooksAccess` to true or false, but element %d sets '%s'" $profile_index $profile.name $member_index $member_access.notebooksAccess) ->}}
    {{<- end ->}}

    {{<- /* unpack this member's `user` or `group` */ ->}}
    {{<- if and (index $member "user") (index $member "group") ->}}
      {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may set EITHER `user` or `group`, but element %d sets both" $profile_index $profile.name $member_index) ->}}
    {{<- else if index $member "group" ->}}
      {{<- /* CASE 1: `group` is specified */ ->}}
      {{<- if has $groups_id_mapping $member.group ->}}
        {{<- $group_users := index $groups_id_mapping $member.group ->}}
        {{<- range $user_id, $user := $group_users ->}}
          {{<- if has $user_access_mapping $user_id ->}}
            {{<- $existing_access := index $user_access_mapping $user_id ->}}

            {{<- /* upgrade `role` to 'edit', if applicable */ ->}}
            {{<- if and (eq $existing_access.role "view") (eq $member_access.role "edit") ->}}
              {{<- $existing_access = coll.Merge (dict "role" "edit") $existing_access ->}}
            {{<- end ->}}

            {{<- /* upgrade `notebookAccess` to true, if applicable */ ->}}
            {{<- if and (eq $existing_access.notebooksAccess false) (eq $member_access.notebooksAccess true) ->}}
              {{<- $existing_access = coll.Merge (dict "notebooksAccess" true) $existing_access ->}}
            {{<- end ->}}

            {{<- $user_access_mapping = coll.Merge (dict $user_id $existing_access) $user_access_mapping ->}}
          {{<- else ->}}
            {{<- if eq $user.email $profile_ownerEmail ->}}
              {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may not include users with same email as profile owner, but group '%s' at index %d includes user '%s' which has email '%s'" $profile_index $profile.name $member.group $member_index $user_id $user.email) ->}}
            {{<- end ->}}

            {{<- $copied_member_access := $member_access | toJSON | json ->}}
            {{<- $user_access_mapping = coll.Merge (dict $user_id $copied_member_access) $user_access_mapping ->}}
          {{<- end ->}}
        {{<- end ->}}
      {{<- else ->}}
        {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may only reference groups that exist in `groups`, but element %d references '%s' which does not exist" $profile_index $profile.name $member_index $member.group) ->}}
      {{<- end ->}}
    {{<- else if index $member "user" ->}}
      {{<- /* CASE 2: `user` is specified */ ->}}
      {{<- if has $users_id_mapping $member.user ->}}
        {{<- $user_id := $member.user ->}}
        {{<- $user := index $users_id_mapping $user_id ->}}
        {{<- if has $user_access_mapping $user_id ->}}
          {{<- $existing_access := index $user_access_mapping $user_id ->}}

          {{<- /* upgrade `role` to 'edit', if applicable */ ->}}
          {{<- if and (eq $existing_access.role "view") (eq $member_access.role "edit") ->}}
            {{<- $existing_access = coll.Merge (dict "role" "edit") $existing_access ->}}
          {{<- end ->}}

          {{<- /* upgrade `notebookAccess` to true, if applicable */ ->}}
          {{<- if and (eq $existing_access.notebooksAccess false) (eq $member_access.notebooksAccess true) ->}}
            {{<- $existing_access = coll.Merge (dict "notebooksAccess" true) $existing_access ->}}
          {{<- end ->}}

          {{<- $user_access_mapping = coll.Merge (dict $user_id $existing_access) $user_access_mapping ->}}
        {{<- else ->}}
          {{<- if eq $user.email $profile_ownerEmail ->}}
            {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may not include users with same email as profile owner, but user '%s' at index %d has email '%s'" $profile_index $profile.name $user_id $member_index $user.email) ->}}
          {{<- end ->}}
          {{<- $copied_member_access := $member_access | toJSON | json ->}}
          {{<- $user_access_mapping = coll.Merge (dict $user_id $copied_member_access) $user_access_mapping ->}}
        {{<- end ->}}
      {{<- else ->}}
        {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') may only reference users that exist in `users`, but element %d references '%s' which does not exist" $profile_index $profile.name $member_index $member.user) ->}}
      {{<- end ->}}
    {{<- else ->}}
      {{<- fail (printf "elements of `profiles[%d].members` (profile name: '%s') must set `user` OR `group`, but element %d sets neither" $profile_index $profile.name $member_index) ->}}
    {{<- end ->}}
  {{<- end ->}}
  {{<- $profiles_users_access_mapping = coll.Merge (dict $full_profile_name $user_access_mapping) $profiles_users_access_mapping ->}}
{{<- end ->}}
{{<- $profiles_users_access_mapping | data.ToJSON ->}}
{{<- end ->}}

##
## A JSON object for looking up the profiles of each user, and the associated access level: {"<user_id>": {"<profile_name>": <access_object>}}
## - USAGE: `$users_profiles_access_mapping_json := tmpl.Exec "deploykf_profiles.users_profiles_access_mapping_json" (dict "Values" .Values "profiles_users_access_mapping" $profiles_users_access_mapping)`
## - RUNTIME: `$users_profiles_access_mapping_json := tmpl.Exec "runtime/deploykf_profiles__users_profiles_access_mapping_json"`
##
{{<- define "deploykf_profiles.users_profiles_access_mapping_json" ->}}
{{<- $profiles_users_access_mapping := .profiles_users_access_mapping ->}}
{{<- $users_profiles_access_mapping := dict ->}}
{{<- range $profile_name, $user_access_mapping := $profiles_users_access_mapping ->}}
  {{<- range $user_id, $user_access := $user_access_mapping ->}}
    {{<- $users_profiles_access_mapping = coll.Merge (dict $user_id (dict $profile_name $user_access)) $users_profiles_access_mapping ->}}
  {{<- end ->}}
{{<- end ->}}
{{<- $users_profiles_access_mapping | data.ToJSON ->}}
{{<- end ->}}