create table ks_event_tracks (
    id                     number        generated by default on null as identity (start with 1) primary key not null
  , event_id               number        not null
  , display_seq            number        not null
  , name                   varchar2(100) not null
  , alias                  varchar2(32)
  , max_sessions           number
  , max_comps              number
  , blind_vote_help        varchar2(4000)
  , committee_vote_help    varchar2(4000)
  , blind_vote_begin_date  date
  , blind_vote_end_date    date
  , committee_vote_begin_date date
  , committee_vote_end_date   date
  , active_ind             varchar2(1)   not null
  , created_by             varchar2(60) default
                             coalesce(
                                 sys_context('APEX$SESSION','app_user')
                               , regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                               , sys_context('userenv','session_user')
                                )
                             not null
  , created_on             date         default sysdate not null
  , updated_by             varchar2(60)
  , updated_on             date
  , constraint ks_event_tracks_ck_active
      check (active_ind in ('Y', 'N'))
  , constraint ks_event_tracks_fk foreign key ( event_id ) references ks_events ( id ) not deferrable
)
enable primary key using index
/

alter table ks_event_tracks modify name varchar2(100);

comment on table ks_event_tracks is 'List of event tracks';

comment on column ks_event_tracks.event_id is 'Event this track belongs to';
comment on column ks_event_tracks.display_seq is 'Order for displaying the lines';
comment on column ks_event_tracks.active_ind is 'Is the record enabled Y/N?';
comment on column ks_event_tracks.max_sessions is 'Number of sessions this track can accept';
comment on column ks_event_tracks.max_comps is 'Number of event comps this track can accept';
comment on column ks_event_tracks.blind_vote_begin_date is 'Track Override for Begin date of blind voting';
comment on column ks_event_tracks.blind_vote_end_date is 'Track Override for End date of blind voting';
comment on column ks_event_tracks.committee_vote_begin_date is 'Track Override for Begin date of committee voting';
comment on column ks_event_tracks.committee_vote_end_date is 'Track Override for End date of committee voting';
comment on column ks_event_tracks.created_by is 'User that created this record';
comment on column ks_event_tracks.created_on is 'Date the record was first created';
comment on column ks_event_tracks.updated_by is 'User that last modified this record';
comment on column ks_event_tracks.updated_on is 'Date the record was last modified';


--------------------------------------------------------
--  DDL for Trigger ks_event_tracks_u_trg
--------------------------------------------------------
create or replace trigger ks_event_tracks_u_trg
before update
on ks_event_tracks
referencing old as old new as new
for each row
begin
  :new.updated_on := sysdate;
  :new.updated_by := coalesce(
                     sys_context('APEX$SESSION','app_user')
                     ,regexp_substr(sys_context('userenv','client_identifier'),'^[^:]*')
                     ,sys_context('userenv','session_user')
                     );
end;
/
alter trigger ks_event_tracks_u_trg enable;
