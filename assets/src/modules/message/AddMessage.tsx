import React, { Component } from "react";
import API from "@aws-amplify/api";
import { Button, FormGroup, FormControl, Modal, FormLabel, Spinner, Form } from "react-bootstrap";
import { Redirect } from "react-router-dom";

import "./AddMessage.css";

interface AddMessageProps {
  match: any;
  history: any;
}

interface AddMessageState {
  isExistingMessage: boolean;
  //isLoading: boolean;
  isUpdating: boolean;
  //isDeleting: boolean;
  message: Message;
  showDeleteModal: boolean;
  redirect: string;
}

interface Message {
  messageId: string;
  //title: string;
  content: string;
}

export default class AddMessage extends Component<AddMessageProps, AddMessageState> {
  constructor(props: AddMessageProps) {
    super(props);

    this.state = {
      redirect: '',
      isExistingMessage: false,
      //isLoading: false,
      isUpdating: false,
      //isDeleting: false,
      showDeleteModal: false,
      message: {
        messageId: '',
        //title: '',
        content: '',
      },
    };
  }
/*
  componentDidMount() {
    const id = this.props.match.params.id;
    if (id) {
      this.getGoal(id);
      this.setState({
        isExistingMessage: true,
      });
    }

  }

  getGoal(goalId: string) {
    this.setState({
      isLoading: true,
    });

    return API.get("goals", `/goals/${goalId}`, null).then((value: any) => {
      this.setState({
        isLoading: false,
        goal: {
          title: value.title,
          content: value.content,
          goalId: this.props.match.params.id,
        }
      });
    });
  }
*/

//Validate only if message.content is between 1-100 characters
  validateForm = () => {
    return this.state.message.content.length < 100 && this.state.message.content.length > 1;
  }

  handleChange = (event: any) => {
    const { id, value } = event.target;
    this.setState({
      message: {
        ...this.state.message,
        [id]: value
      }
    } as any);
  }

  handleCancel = (event: any) => {
    this.setState({
      redirect: '/'
    });
  }

  handleSubmit = async (event: any) => {
    this.setState ({
      isUpdating: true,
    });
    event.preventDefault();
    this.state.isExistingGoal ? this.updateGoal() : this.saveGoal();
  }
/*
  updateGoal = () => {
    const { goal } = this.state;
    return API.put("goals", `/goals/${this.props.match.params.id}`, {
      body: {
        title: goal.title,
        content: goal.content
      }
    }).then((value: any) => {
      this.setState({
        isUpdating: false,
        redirect: '/'
      });
    });
  }
*/
  saveGoal = () => {
    const { goal } = this.state;
    return API.post("goals", "/goals", {
      body: {
        title: goal.title,
        content: goal.content
      }
    }).then((value: any) => {
      this.setState({
        isUpdating: false,
        redirect: '/'
      });
    });
  }
/*
  showDeleteModal = (shouldShow: boolean) => {
    this.setState({
      showDeleteModal: shouldShow
    });
  }

  handleDelete = (event: any) => {
    this.setState({
      isDeleting: true,
    })

    return API.del("goals", `/goals/${this.props.match.params.id}`, null).then((value: any) => {
      this.setState({
        isDeleting: false,
        showDeleteModal: false,
        redirect: '/'
      });
    });

  }

  deleteModal() {
    return (
      <Modal
        show={this.state.showDeleteModal}
        onHide={() => this.showDeleteModal(false)}
        container={this}
        aria-labelledby="contained-modal-title"
        id="contained-modal">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title">Delete goal</Modal.Title>
        </Modal.Header>
        <Modal.Body>
          Are you sure you want to delete this goal?
        </Modal.Body>
        <Modal.Footer>
          <Button
            variant="danger"
            onClick={this.handleDelete}>
            {this.state.isDeleting ?
              <span><Spinner size="sm" animation="border" className="mr-2" />Deleting</span> :
              <span>Delete</span>}
            </Button>
        </Modal.Footer>
      </Modal>
    );
  }
*/
  render() {
    const { goal, isExistingGoal, showDeleteModal, redirect } = this.state;

    if (redirect) {
      return <Redirect push to={redirect} />;
    }

    return (
      <div className="goal">
        {this.state.isLoading ? 
          <Spinner animation="border" className="center-spinner" /> : 

          <Form noValidate onSubmit={this.handleSubmit}>

            <div className="form-body">
              <FormGroup className="blinking-cursor">
                <FormLabel>Goal title</FormLabel>
                <FormControl id="title"
                  onChange={this.handleChange}
                  value={goal.title}
                  minLength={1}
                  isValid={goal.title.length > 0}
                  placeholder="Enter goal title.."
                  required />
              </FormGroup>

              <FormGroup >
                <FormLabel>Goal description</FormLabel>
                <FormControl id="content"
                  onChange={this.handleChange}
                  value={goal.content}
                  minLength={1}
                  isValid={goal.content.length > 0}
                  placeholder="Enter goal description.."
                  as="textarea"
                  required />
              </FormGroup>
            </div>

            {isExistingGoal &&
              <Button
                variant="outline-danger"
                onClick={() => this.showDeleteModal(true)}>
                Delete
              </Button>}

            <Button
              variant="primary"
              type="submit"
              disabled={!this.validateForm()}
              className="float-right"
              onClick={this.handleSubmit}>
              {this.state.isUpdating ?
                <span><Spinner size="sm" animation="border" className="mr-2" />{isExistingGoal ? 'Updating' : 'Creating'}</span> :
                <span>{isExistingGoal ? 'Update goal' : 'Create goal'}</span>}
            </Button>

            <Button
              variant="link"
              onClick={this.handleCancel}
              className="float-right">
              Cancel
            </Button>
          </Form>}

        {showDeleteModal && this.deleteModal()}
        
      </div>
    );
  }
}