# --- Add answer options for multi-option questions
# --- !Ups

alter table applicants add whenCreated timestamp;

update applicants set whenCreated = current_timestamp where whenCreated is null;

# --- !Downs

alter table applicants drop column whenCreated;
