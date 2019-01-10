import React, { Component } from 'react';
import PropTypes from 'prop-types';

import {
  Platform,
  Keyboard,
  NativeModules,
  TextInput,
  findNodeHandle,
  AppRegistry,
} from 'react-native';

const { CustomKeyboard } = NativeModules;
const {
  install,
  uninstall,
  hideKeyboard,
  submitEditing,
  insertText,
  backSpace,
  doDelete,
  moveLeft,
  moveRight,
  switchSystemKeyboard,
} = CustomKeyboard;

const keyboardTypeRegistry = {};

export function register(type, factory) {
  keyboardTypeRegistry[type] = factory;
}

class CustomKeyboardContainer extends Component {
  render() {
    const { tag, type } = this.props;
    const factory = keyboardTypeRegistry[type];

    if (!factory) {
      console.warn(`Custom keyboard type ${type} not registered.`);
      return null;
    }
    
    const Comp = factory();
    return <Comp tag={tag} />;
  }
}

AppRegistry.registerComponent("CustomKeyboard", () => CustomKeyboardContainer);

export class CustomTextInput extends Component {
  static propTypes = {
    ...TextInput.propTypes,
    customKeyboardType: PropTypes.string,
  };

  componentDidMount() {
    install(findNodeHandle(this.input), this.props.customKeyboardType);
  }

  componentWillUnmount() {
    uninstall(findNodeHandle(this.input));
    this.input = undefined;
  }

  componentWillReceiveProps(newProps) {
    if (newProps.customKeyboardType !== this.props.customKeyboardType) {
      install(findNodeHandle(this.input), newProps.customKeyboardType);
    }
  }

  onRef = ref => {
    this.props.onCustomInputRef(ref);
    this.input = ref;
  };

  render() {
    const { customKeyboardType, ...others } = this.props;
    return <TextInput {...others} ref={this.onRef} />;
  }
}

export {
  install,
  uninstall,
  submitEditing,
  hideKeyboard,
  insertText,
  backSpace,
  doDelete,
  moveLeft,
  moveRight,
  switchSystemKeyboard,
};
