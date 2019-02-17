#!/usr/bin/python
#
# Export utility for transforming Confluence wiki content into a format and
# structure consumable by ServiceNow Knowledge. Designed to run on the
# Confluence server.
#
# This utility runs in four main modes, listed below.
#
# attachments:

# Look up attachments in the ATTAHCMENTS table and copy them out of the local
# filesystem, adding them to a zip archive in a flat list. Attachment
# filenames are rewritten to pageid-attachmentfilename to allow easy
# association  with pages. In a future version we may add ServiceNow API
# integration to automatically  upload them via the API and attach them to
# their respective parent articles in ServiceNow. This usually needs to be run
# on the Confluence server to allow access to attachments stored in the server
# file system.

# images:                 

# Run through all pages and scan for IMG SRC tags to identify most attachments
# (usually images) that are displayed inline and a) locate and copy the
# attachment follwing the new attachment naming convention of pageid-filename
# and add it to a zipfile; b) rewrite the content block with updated SRC
# references to point to the new filename

#                --content
#                  Run through all current versions of pages and extract the
#                  wiki markup content; convert it to HTML using Confluence's
#                  conversion engine; write it into a new database table as
#                  HTML
#
# Author: Oliver Thomas <othomas@mit.edu>
# Created: 2015-09-08
#
# MySQL Connector Python is available at:
# http://dev.mysql.com/downloads/connector/python/


import sys
import string
import os
import getpass
import re
import argparse
import requests
import json
import xmlrpclib
import zipfile
import datetime
import mysql.connector

from servicenow import ServiceNow
from servicenow import Connection

mcxn = { 'user' : 'snreader', 'password' : '', 'host' : 'dolios.mit.edu', 'database' : 'confluence', 'raise_on_warnings' : True, }
ccxn = { 'username' : 'othomas', 'password' : '', 'server' : 'dolios.mit.edu' , 'uri' : 'https://{server}/confluence/rpc/xmlrpc'}

defaults = { 'process' : 'all', 'limit' : 0, 'files' : False, 'spacekey' : '' , 'contentzip' : 'content.zip', 'imageszip' : 'images.zip', 'attachmentszip' : 'attachments.zip', 'htmltable' : 'HTMLCONTENT', 'readonly' : False, 'force' : False, 'truncate' : False }

def main(**kwargs):
	# A little preperatory setup and staging -- ask for missing data

	# Verify a complete set of MySQL and Confluence connection settings
	if kwargs['mserver']: mcxn['host'] = kwargs['mserver']
	if kwargs['mdatabase']: mcxn['database'] = kwargs['mdatabase']
	if kwargs['muser']: mcxn['user'] = kwargs['muser']
	if kwargs['mpass']: mcxn['password'] = kwargs['mpass']

	if kwargs['cserver']: ccxn['server'] = kwargs['cserver']
	if kwargs['cuser']: ccxn['username'] = kwargs['cuser']
	if kwargs['cpass']: ccxn['password'] = kwargs['cpass']

	ccxn['uri'] = ccxn['uri'].format(server = ccxn['server'])

	# Although default passwords can be set in the connection configuration variables, it's probably not a good idea
	if not mcxn['password']: mcxn['password'] = getpass.getpass('     MySQL Password: ')
	if not ccxn['password']: ccxn['password'] = getpass.getpass('Confluence Password: ')

	vprint("")
	vprint("     MySQL: {username}@{server}:{database}".format(username=mcxn['user'], server=mcxn['host'], database=mcxn['database']))
	vprint("Confluence: {username}@{server}".format(username=ccxn['username'], server=ccxn['server']))
	vprint("")

	# Update defaults with command line arguments
	if kwargs['attachments']: defaults['process'] = 'attachments'
	if kwargs['images']: defaults['process'] = 'images'
	if kwargs['content']: defaults['process'] = 'content'

	vprint("Process: {process}".format(process=defaults['process']))
	vprint("")

	# Update default processing flags with command line arguments
	if kwargs['files']: defaults['files'] = True
	if kwargs['readonly']: defaults['readonly'] = True
	if kwargs['spacekey']: defaults['spacekey'] = kwargs['spacekey']
	if kwargs['limit']: defaults['limit'] = kwargs['limit']
	if kwargs['force']: defaults['force'] = True
	if kwargs['truncate']: defaults['truncate'] = True

	vprint("Write content to files: {flag}".format(flag=str(defaults['files'])))
	vprint(" Read and display only: {flag}".format(flag=str(defaults['readonly'])))
	vprint("      Limit to process: {limit}".format(limit=str(defaults['limit'])))
	vprint("")

	# Check for existing output files and ask whether to overwrite
	if zipfile.is_zipfile(defaults['imageszip']) and ( defaults['process'] == 'all' or defaults['process'] == 'images' ) and not defaults['force']:
		overwrite = raw_input("Output file {file} exists. Overwrite? [y/N]: ".format(file=defaults['imageszip']))
		if overwrite.lower() != 'y':
			vprint("Output file {file} exists. Exiting.".format(file=defaults['imageszip']))
			exit()
		else:
			vprint("Okay to overwrite {file}. Continuing.".format(file=defaults['imageszip']))
			vprint("")
	if zipfile.is_zipfile(defaults['attachmentszip']) and ( defaults['process'] == 'all' or defaults['process'] == 'attachments' ) and not defaults['force']:
		overwrite = raw_input("Output file {file} exists. Overwrite? [y/N]: ".format(file=defaults['attachmentszip'])) 
		if overwrite.lower() != 'y':
			vprint("Output file {file} exists. Exiting.".format(file=defaults['attachmentszip']))
			exit()
		else:
			vprint("Okay to overwrite {file}. Continuing.".format(file=defaults['attachmentszip']))
			vprint("")
	if zipfile.is_zipfile(defaults['contentzip']) and ( defaults['process'] == 'all' or defaults['process'] == 'images') and defaults['files'] and not defaults['force']:
		overwrite = raw_input("Output file {file} exists. Overwrite? [y/N]: ".format(file=defaults['contentzip']))
		if overwrite.lower() != 'y':
			vprint("Output file {file} exists. Exiting.".format(file=defaults['contentzip']))
			exit()
		else:
			vprint("Okay to overwrite {file}. Continuing.".format(file=defaults['contentzip']))
			vprint("")

	# Confirm it's okay to truncate content table if writing to content table is on the agenda and truncate flag is not set
	if not defaults['files'] and ( defaults['process'] == 'all' or defaults['process'] == 'content' ) and not defaults['truncate']:
		overwrite = raw_input("Are you sure you want to truncate {table} and re-create it? [y/N]: ".format(table=defaults['htmltable']))
		if overwrite.lower() != 'y':
			vprint("You chose not to truncate {table}. Exiting.".format(table=defaults['htmltable']))
			exit()
		else:
			vprint("Okay to truncate. Continuing.")
			vprint("")

	# Create needed database and API connections

	vprint("Connecting to MySQL database {database} on {server} as {username}.".format(database=mcxn['database'],server=mcxn['host'],username=mcxn['user']))
	dbcxn = mysql.connector.connect(**mcxn)
	vprint("Success.")
	vprint("")

	vprint("Connecting to Confluence XML-RPC API at {uri}".format(uri=ccxn['uri']))
	cserver = xmlrpclib.ServerProxy(ccxn['uri'])
	ctoken = cserver.confluence1.login(ccxn['username'], ccxn['password'])
	vprint("Success.")
	vprint("")

	# Construct MySQL query to return all content IDs for most recent versions of page content, optionally filtering by
	# space key and cutting off at limit.
	contentcursor = dbcxn.cursor()

#	# The below is a more complete query created for ServiceNow to fetch content meta data from Confluence. Keeping it here for reference.
#	contentquery = ("SELECT CONTENT.contentid AS pageid, CONTENT.contenttype AS type, CONTENT.version AS version, CONTENT.creator AS creator, "
#		"CONTENT.creationdate AS created, CONTENT.lastmodifier AS lastmodifier, CONTENT.lastmoddate AS lastmodified, SPACES.spacekey AS spacekey, CONTENT.title AS title "
#		"FROM CONTENT, SPACES where CONTENT.contenttype = 'PAGE' and CONTENT.prevver is NULL and CONTENT.content_status = 'current' and CONTENT.spaceid = SPACES.spaceid "
#		"ORDER BY SPACES.spacekey, CONTENT.title ")

	query = ("SELECT CONTENT.contentid, CONTENT.lastmoddate, SPACES.spacekey, CONTENT.title "
		"FROM CONTENT, SPACES where CONTENT.contenttype = 'PAGE' and CONTENT.prevver is NULL and CONTENT.content_status = 'current' and CONTENT.spaceid = SPACES.spaceid ")
	if defaults['spacekey']:
		query += "and SPACES.spacekey = '{spacekey}' ".format(spacekey=defaults['spacekey'])
	query += "ORDER BY CONTENT.contentid "
	if defaults['limit']:
		query += "LIMIT {limit} ".format(limit=str(defaults['limit']))

	vprint("Constructed content query:")
	vprint(query)
	vprint("")

	# Cursor through content query and populate a list of tuples
	contentcursor.execute(query)
	content = []
	for row in contentcursor:
		content.append(row)
	contentcursor.close()

	# The below code block needs work. We're doing too many conditionals to account for the DB / Files fork.
	# This is better implemented via a save/store function that appropriately writes to DB or files rather than
	# individual conditionals.

	# If files flag is set, open content zip file and ready for writing
	if defaults['files']:
		contentfile = zipfile.ZipFile(defaults['contentzip'], mode = 'w', compression = zipfile.ZIP_STORED, allowZip64 = True)
	else:
		vprint("Trunacting table {table}.".format(table=defaults['htmltable']))
		query = "TRUNCATE TABLE {table} ".format(table=defaults['htmltable']) 
		truncatecursor = dbcxn.cursor()
		truncatecursor.execute(query)
		htmlcursor = dbcxn.cursor()
		query = "INSERT INTO {table} ".format(table=defaults['htmltable'])
		query += "(HTMLCONTENTID, CONTENTID, HTML, LASTMODDATE) VALUES (%s, %s, %s, %s)"
		vprint("Created DB cursor for query {query}.".format(query=query))

	# Examine records
	start = datetime.datetime.now()
	split = datetime.datetime.now()
	contentindex = 0
	reportinterval = 100

	vprint("Processing {count} articles...".format(count=str(len(content))))
	vprint("")
	for contentitem in content:
		# Fetch HTML block via XMLRPC call to Confluence for pageid in record
#		vprint("{count}:  Fetching HTML version of {pageid} via Confluence XML-RPC API...".format(count=str(contentindex), pageid=str(contentitem[0])))
		try:
			htmlbuffer = cserver.confluence1.renderContent(ctoken, '', str(contentitem[0]), '')
		except:
			print "Error fetching converted article {pageid}:".format(pageid=contentitem[0])
			continue 

		if defaults['files']:
			# Write HTML to file if files flag is set
			htmlfile = "{pageid}.html".format(pageid=str(contentitem[0]))
			with open(htmlfile, 'w') as target:
				target.write(htmlbuffer.encode('utf_8'))
			contentfile.write(htmlfile)
			os.remove(htmlfile)
#			vprint("  ...added file {file} to zip archive {zipfile}".format(file=htmlfile, zipfile=defaults['contentzip']))
		else:
			# Write HTML to database if files flag is not set
			lastmoddate = datetime.datetime.now()
			try:
				htmlcursor.execute(query, (contentindex, contentitem[0], htmlbuffer.encode('utf_8'), lastmoddate))
				dbcxn.commit()
			except mysql.connector.errors.DatabaseError as e:
				print "Error writing {pageid} to database. Bad characters.".format(pageid=contentitem[0])
				print e

		contentindex += 1
		if contentindex % reportinterval == 0:
			stop = datetime.datetime.now()
			vprint("Completed {count} articles. Last {interval} in {time} seconds. Total of {totaltime} seconds elapsed.".format(count=contentindex, interval=reportinterval, time=stop - split, totaltime=stop - start))
			split = stop

	# Close zip file if files flag is set
	if defaults['files']:
		contentfile.close()
		

	stop = datetime.datetime.now()
	delta = stop - start
	vprint("")
	vprint("Finished processing {count} articles in {totaltime} seconds.".format(count=str(len(content)), totaltime=delta.seconds))

		
	## Parse HTML for IMG tags
	## Replace SRC element with updated file name pageid-filename and no directory path
	# Update or Insert HTML block to htmltable in database depending on comparisong of date stamp in htmltable

#	# For testing we create the three zip files to check overwrite logic above
#	attachmentsfile = zipfile.ZipFile(defaults['attachmentszip'], mode = 'w', compression = zipfile.ZIP_STORED, allowZip64 = True)
#	imagesfile = zipfile.ZipFile(defaults['imageszip'], mode = 'w', compression = zipfile.ZIP_STORED, allowZip64 = True)
#	contentfile = zipfile.ZipFile(defaults['contentzip'], mode = 'w', compression = zipfile.ZIP_STORED, allowZip64 = True)
#	attachmentsfile.close()
#	imagesfile.close()
#	contentfile.close()

	# Close database connection
	dbcxn.close()

if __name__ == '__main__':
	parser = argparse.ArgumentParser()
	parser.add_argument("-a", "--attachments", action="store_true", help="Process Confluence attachments into ZIP archive")
	parser.add_argument("-c", "--content", action="store_true", help="Process Confluence content into HTML version")
	parser.add_argument("-i", "--images", action="store_true", help="Process Confluence inline images into a ZIP archive and rewrite HTML content to match")
	parser.add_argument("-s", "--spacekey", help="Specify a space key to limit operations to articles in space")
	parser.add_argument("-l", "--limit", type=int, help="Limit operations to first LIMIT records -- useful to speed up testing")
	parser.add_argument("-f", "--files", action="store_true", help="Write output to HTML files in ZIP archive instead of database records")
	parser.add_argument("-r", "--readonly", action="store_true", help="Don't write anything -- useful for testing")
	parser.add_argument("-F", "--force", action="store_true", help="Overwrite output files as needed without prompting")
	parser.add_argument("-T", "--truncate", action="store_true", help="Truncate output table as needed without prompting")
	parser.add_argument("-m", "--muser", help="MySQL username")
	parser.add_argument("-n", "--mpass", help="MySQL password")
	parser.add_argument("-o", "--mserver", help="MySQL server")
	parser.add_argument("-p", "--mdatabase", help="MySQL database")
	parser.add_argument("-x", "--cuser", help="Confluence username")
	parser.add_argument("-y", "--cpass", help="Confluence password")
	parser.add_argument("-z", "--cserver", help="Confluence server")
	parser.add_argument("-v", "--verbose", action="store_true", help="Verbose mode -- useful for debugging")
	args = parser.parse_args()

	if vars(args)['verbose']:
		def vprint(*vprintargs):
			for vprintarg in vprintargs:
				print vprintarg,
			print
	else:
		vprint = lambda *a: None      # do-nothing function

	vprint("")
	vprint("Verbose mode is on.")
	vprint("")

	main(**vars(args))




