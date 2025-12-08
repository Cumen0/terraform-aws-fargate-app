import os
import uuid
from datetime import datetime
from flask import Flask, render_template, request, jsonify, redirect, url_for
import boto3
from botocore.exceptions import ClientError

app = Flask(__name__)

# Initialize DynamoDB resource
# Authentication is handled via IAM Task Role
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')

# Get table name from environment variable
TABLE_NAME = os.environ.get('DYNAMODB_TABLE', 'todo-table-dev')
table = dynamodb.Table(TABLE_NAME)


def get_all_tasks():
    """Retrieve all tasks from DynamoDB"""
    try:
        response = table.scan()
        tasks = response.get('Items', [])
        # Sort by created_at descending (newest first)
        tasks.sort(key=lambda x: x.get('created_at', ''), reverse=True)
        return tasks
    except ClientError as e:
        app.logger.error(f"Error scanning DynamoDB table: {e}")
        return []


@app.route('/')
def index():
    """Render the main page with all tasks"""
    tasks = get_all_tasks()
    return render_template('index.html', tasks=tasks)


@app.route('/add', methods=['POST'])
def add_task():
    """Add a new task to DynamoDB"""
    try:
        task_text = request.form.get('task', '').strip()

        if not task_text:
            return jsonify({'error': 'Task cannot be empty'}), 400

        task_id = str(uuid.uuid4())
        created_at = datetime.utcnow().isoformat()

        item = {
            'id': task_id,
            'task': task_text,
            'status': 'todo',
            'created_at': created_at
        }

        table.put_item(Item=item)

        return redirect(url_for('index'))
    except ClientError as e:
        app.logger.error(f"Error adding task to DynamoDB: {e}")
        return jsonify({'error': 'Failed to add task'}), 500
    except Exception as e:
        app.logger.error(f"Unexpected error: {e}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@app.route('/complete/<task_id>', methods=['POST'])
def complete_task(task_id):
    """Update task status to 'done'"""
    try:
        table.update_item(
            Key={'id': task_id},
            UpdateExpression='SET #status = :status',
            ExpressionAttributeNames={
                '#status': 'status'
            },
            ExpressionAttributeValues={
                ':status': 'done'
            }
        )
        return redirect(url_for('index'))
    except ClientError as e:
        app.logger.error(f"Error updating task in DynamoDB: {e}")
        return jsonify({'error': 'Failed to complete task'}), 500
    except Exception as e:
        app.logger.error(f"Unexpected error: {e}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


@app.route('/delete/<task_id>', methods=['POST'])
def delete_task(task_id):
    """Delete a task from DynamoDB"""
    try:
        table.delete_item(Key={'id': task_id})
        return redirect(url_for('index'))
    except ClientError as e:
        app.logger.error(f"Error deleting task from DynamoDB: {e}")
        return jsonify({'error': 'Failed to delete task'}), 500
    except Exception as e:
        app.logger.error(f"Unexpected error: {e}")
        return jsonify({'error': 'An unexpected error occurred'}), 500


if __name__ == '__main__':
    # Only for local development
    app.run(host='0.0.0.0', port=80, debug=False)
