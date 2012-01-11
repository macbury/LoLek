worker_importer: ./script/delayed_job start -m --min-priority 1 --prefix importer
worker_assets: ./script/delayed_job start -m --min-priority 0 --max-priority 0 --prefix assets
worker_actions: ./script/delayed_job start -m --max-priority -1 --prefix actions
