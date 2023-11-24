import React, { Component } from "react";
import { Button, Table, Spinner } from "react-bootstrap";
import API from "@aws-amplify/api";
import { Redirect } from "react-router-dom";

import fullStack from "../../images/full-stack.png";
import "./home.css";

interface HomeProps {
  isAuthenticated: boolean;
}

interface HomeState {
  isLoading: boolean;
  messages: Message[];
  redirect: boolean;
}

interface Message {
  content: string;
  messageId: string;
  //title: string;
  createdAt: Date;
}

export default class Home extends Component<HomeProps, HomeState> {
  constructor(props: HomeProps) {
    super(props);

    this.state = {
      isLoading: true,
      messages: [],
      redirect: false,
    };
  }

  async componentDidMount() {
    if (!this.props.isAuthenticated) {
      return;
    }

    try {
      const messages = await this.messages();
      this.setState({ messages });
    } catch (e) {
      alert(e);
    }

    this.setState({ isLoading: false });
  }

  messages() {
    return API.get("messages", "/message", null);
  }

  renderMessagesList(messages: Message[]) {
    let messagesList: Message[] = [];

    return messagesList.concat(messages).map(
      (message, i) =>
        <tr key={message.messageId}>
          <td><div className="description">{message.content.trim().split("\n")[0]}</div></td>
          <td>{new Date(message.createdAt).toLocaleString()}</td>
        </tr>
    );
  }

  onCreate = () => {
    this.setState({ redirect: true });
  }

  renderLanding() {
    return (
      <div className="lander">
        <h2>Answering Machine App</h2>
        <hr />
        <p>This is an application where users can leave me a message on my answering machine. More info can be found on the <a className="orange-link" href="https://github.com/awslabs/aws-full-stack-template" target="_blank">github repository</a>.</p>
        <div className="button-container col-md-12">
          <a href="/signup" className="orange-link">Sign up or log in to leave a message</a>
        </div>
        <img src={fullStack} className="img-fluid full-width" alt="Screenshot"></img>
      </div>);
  }

  renderHome() {
    return (
      <div className="goals">
        <h1 className="text-center">Leave me a message...</h1>
        <div className="mb-3 float-right">
          <Button variant="primary" onClick={this.onCreate}>Send new message</Button>
        </div>
        <Table variant="dark'">
          <thead>
            <tr>
              <th>Message Content</th>
              <th>Date created</th>
            </tr>
          </thead>
          <tbody>
              {
                this.state.isLoading ?
                (
                  <tr><td>
                    <Spinner animation="border" className="center-spinner" />
                  </td></tr>
                ) :
                this.renderMessagesList(this.state.messages)
            }
          </tbody>
        </Table>
      </div>
    );
  }

  render() {
    let { redirect } = this.state;
    if (redirect) {
      return <Redirect push to={'/message/'} />;
    }

    return (
      <div className="Home">
        {this.props.isAuthenticated ? this.renderHome() : this.renderLanding()}
      </div>
    );
  }
}
